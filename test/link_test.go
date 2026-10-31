package resumescan

import (
	"bufio"
	"fmt"
	"net/http"
	"os"
	"path/filepath"
	"regexp"
	"runtime"
	"strings"
	"sync"
	"testing"
	"time"
)

// linkRegex matches URLs in LaTeX/Markdown source files.
// Strips trailing punctuation by not including it in the character class.
var linkRegex = regexp.MustCompile(`https?://[^\s{}<>"\)\]\*\},]+`)

// linkSource holds metadata about where a URL was found.
type linkSource struct {
	url    string
	file   string
	lineNo int
}

// linkResult holds the outcome of a single URL check.
type linkResult struct {
	url    string
	pass   bool
	issue  string
	file   string
	lineNo int
}

func TestLinkIntegrity(t *testing.T) {
	// Resolve the resume root relative to this test file's location,
	// not the current working directory — makes tests portable under go workspaces.
	_, file, _, _ := runtime.Caller(0)
	testDir := filepath.Dir(file)
	rootDir := filepath.Dir(testDir)

	// Collect all .tex/.md files first (no walking yet).
	var sourceFiles []string
	if err := filepath.Walk(rootDir, func(path string, info os.FileInfo, err error) error {
		if err != nil {
			return err
		}
		// Skip hidden directories by inspecting the base name.
		if info.IsDir() && strings.HasPrefix(info.Name(), ".") {
			return filepath.SkipDir
		}
		// Only scan source/documentation files.
		ext := filepath.Ext(path)
		if ext != ".tex" && ext != ".md" {
			return nil
		}
		sourceFiles = append(sourceFiles, path)
		return nil
	}); err != nil {
		t.Fatalf("failed to walk repository for source files: %v", err)
	}

	if len(sourceFiles) == 0 {
		t.Fatal("no .tex or .md source files found")
	}

	// Extract unique links with their file context.
	seen := make(map[string]bool)
	var allLinks []linkSource

	for _, path := range sourceFiles {
		content, err := os.ReadFile(path)
		if err != nil {
			t.Logf("skip unreadable file: %s", path)
			continue
		}

		scanner := bufio.NewScanner(strings.NewReader(string(content)))
		lineNo := 0
		for scanner.Scan() {
			lineNo++
			line := scanner.Text()
			matches := linkRegex.FindAllString(line, -1)
			for _, rawURL := range matches {
				if !seen[rawURL] {
					seen[rawURL] = true
					allLinks = append(allLinks, linkSource{url: rawURL, file: path, lineNo: lineNo})
				}
			}
		}
	}

	if len(allLinks) == 0 {
		t.Fatal("no links found in source files")
	}

	// Check all links concurrently (bounded concurrency to avoid hammering servers).
	const maxConcurrency = 10
	sem := make(chan struct{}, maxConcurrency)
	var mu sync.Mutex
	resultsCh := make(chan linkResult, len(allLinks))

	var wg sync.WaitGroup
	wg.Add(len(allLinks))
	for _, l := range allLinks {
		go func(l linkSource) {
			defer wg.Done()
			sem <- struct{}{}
			defer func() { <-sem }()

			result := checkLink(l)
			mu.Lock()
			resultsCh <- result
			mu.Unlock()
		}(l)
	}

	go func() {
		wg.Wait()
		close(resultsCh)
	}()

	passed := 0
	failed := 0
	for r := range resultsCh {
		title := fmt.Sprintf("Link:%s (line %d in %s)", filepath.Base(r.url), r.lineNo, filepath.ToSlash(strings.TrimPrefix(r.file, rootDir+"/")))
		if r.pass {
			t.Run(title, func(t *testing.T) { /* pass */ })
			passed++
		} else {
			t.Run(title, func(t *testing.T) {
				t.Error(r.issue)
			})
			failed++
		}
	}

	t.Logf("link check complete: %d passed, %d failed out of %d total", passed, failed, passed+failed)
}

// checkLink validates a single URL and returns the result.
func checkLink(l linkSource) linkResult {
	url := l.url

	// Security Check: Enforce HTTPS only.
	if strings.HasPrefix(url, "http://") {
		return linkResult{url: url, pass: false, issue: fmt.Sprintf("Security Risk: Insecure HTTP link found: %s (line %d in %s). Upgrade to HTTPS.", url, l.lineNo, filepath.Base(l.file)), file: l.file, lineNo: l.lineNo}
	}

	client := &http.Client{
		Timeout: 15 * time.Second,
		CheckRedirect: func(req *http.Request, via []*http.Request) error {
			if len(via) >= 5 {
				return fmt.Errorf("too many redirects")
			}
			return nil
		},
	}

	// Liveness Check: HEAD first, GET fallback for servers that block HEAD.
	resp, err := doWithFallback(client, url)
	if err != nil {
		return linkResult{url: url, pass: false, issue: fmt.Sprintf("Connection Error: Failed to reach %s (line %d in %s): %v", url, l.lineNo, filepath.Base(l.file), err), file: l.file, lineNo: l.lineNo}
	}
	defer resp.Body.Close()

	// Classify status codes.
	switch {
	case resp.StatusCode >= 200 && resp.StatusCode < 400:
		return linkResult{url: url, pass: true, file: l.file, lineNo: l.lineNo}
	case resp.StatusCode == 403:
		return linkResult{url: url, pass: false, issue: fmt.Sprintf("Forbidden (403): %s (line %d in %s). Resource may require authentication or be unavailable.", url, l.lineNo, filepath.Base(l.file)), file: l.file, lineNo: l.lineNo}
	case resp.StatusCode == 404:
		return linkResult{url: url, pass: false, issue: fmt.Sprintf("Not Found (404): %s (line %d in %s).", url, l.lineNo, filepath.Base(l.file)), file: l.file, lineNo: l.lineNo}
	default:
		return linkResult{url: url, pass: false, issue: fmt.Sprintf("Unexpected status %d for %s (line %d in %s).", resp.StatusCode, url, l.lineNo, filepath.Base(l.file)), file: l.file, lineNo: l.lineNo}
	}
}

// doWithFallback attempts HEAD first, then GET if HEAD fails.
func doWithFallback(client *http.Client, url string) (*http.Response, error) {
	resp, err := client.Head(url)
	if err == nil && resp.StatusCode < 500 {
		return resp, nil
	}
	// HEAD failed or returned server error — retry with GET.
	if resp != nil {
		resp.Body.Close()
	}

	resp, err = client.Get(url)
	if err != nil {
		return nil, fmt.Errorf("HEAD and GET both failed for %s: %w", url, err)
	}
	return resp, nil
}
