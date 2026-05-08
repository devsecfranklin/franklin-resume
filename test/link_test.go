package test

import (
	"fmt"
	"net/http"
	"os"
	"path/filepath"
	"regexp"
	"strings"
	"testing"
	"time"
)

func TestLinkIntegrity(t *testing.T) {
	linkRegex := regexp.MustCompile(`https?://[^\s{}<>"]+`)
	uniqueLinks := make(map[string]bool)
	
	// Corrected signature: must include info and err arguments
	err := filepath.Walk("..", func(path string, info os.FileInfo, err error) error {
		if err != nil {
			return err
		}
		// Only scan source/documentation files [cite: 283, 288]
		if !strings.HasSuffix(path, ".tex") && !strings.HasSuffix(path, ".md") {
			return nil
		}
		// Skip hidden directories like .git [cite: 277]
		if strings.Contains(path, "/.") {
			return nil
		}

		content, err := os.ReadFile(path)
		if err != nil {
			return err
		}

		matches := linkRegex.FindAllString(string(content), -1)
		for _, link := range matches {
			cleanLink := strings.TrimRight(link, "}")
			uniqueLinks[cleanLink] = true
		}
		return nil
	})

	if err != nil {
		t.Fatalf("Failed to crawl repository for links: %v", err)
	}

	client := &http.Client{Timeout: 10 * time.Second}

	for link := range uniqueLinks {
		t.Run(fmt.Sprintf("Link:%s", link), func(t *testing.T) {
			// Security Check: Enforce HTTPS [cite: 283, 287]
			if strings.HasPrefix(link, "http://") {
				t.Errorf("Security Risk: Insecure HTTP link found: %s. Upgrade to HTTPS.", link)
			}

			// Liveness Check: Ensure the link isn't broken 
			resp, err := client.Head(link)
			if err != nil {
				resp, err = client.Get(link)
			}

			if err != nil {
				t.Errorf("Connection Error: Failed to reach %s: %v", link, err)
				return
			}
			defer resp.Body.Close()

			if resp.StatusCode >= 400 {
				t.Errorf("Broken Link: %s returned status code %d", link, resp.StatusCode)
			}
		})
	}
}