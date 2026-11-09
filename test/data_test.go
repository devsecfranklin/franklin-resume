package resumescan

import (
	"os"
	"path/filepath"
	"regexp"
	"strings"
	"testing"
)

// TestSectionDataFiles verifies that all required section data .tex files exist
// and contain non-empty content. No third-party dependencies are used.
func TestSectionDataFiles(t *testing.T) {
	rootDir := ".."
	sectionsDir := filepath.Join(rootDir, "resume", "sections")

	requiredFiles := []string{
		"experience.tex",
		"education.tex",
		"skills/skills.tex",
	}

	for _, name := range requiredFiles {
		path := filepath.Join(sectionsDir, name)

		_, err := os.Stat(path)
		if os.IsNotExist(err) {
			t.Errorf("Missing required section file: %s", path)
			continue
		}
		if err != nil {
			t.Fatalf("Cannot stat %s: %v", path, err)
		}

		data, err := os.ReadFile(path)
		if err != nil {
			t.Errorf("Cannot read %s: %v", path, err)
			continue
		}

		content := strings.TrimSpace(string(data))
		if content == "" {
			t.Errorf("Section file is empty: %s", path)
		}

		// Check that a \resumeitem or equivalent entry marker exists
		entryRegex := regexp.MustCompile(`\\(?:(?:sub)?resume(?:item)?|item(?:ize)?|skills)\b`)
		hasEntry := false
		for _, line := range strings.Split(string(data), "\n") {
			if len(strings.TrimSpace(line)) > 0 && !strings.HasPrefix(strings.TrimSpace(line), "%") {
				if entryRegex.MatchString(line) {
					hasEntry = true
					break
				}
			}
		}
		if !hasEntry {
			t.Errorf("Section file %s has no valid entry markers (expected \\\\resumeitem or \\\\item)", name)
		}
	}

	// Verify the directory itself is readable and contains only expected tex files
	entries, err := os.ReadDir(sectionsDir)
	if err != nil {
		t.Fatalf("Cannot read sections directory %s: %v", sectionsDir, err)
	}
	for _, entry := range entries {
		if !entry.IsDir() && filepath.Ext(entry.Name()) != ".tex" {
			t.Errorf("Unexpected non-.tex file in _sections: %s", entry.Name())
		}
	}
}

// TestDataFileSchemaConsistency validates that each section data file uses
// consistent naming conventions and date formats without relying on external tools.
func TestDataFileSchemaConsistency(t *testing.T) {
	rootDir := ".."
	sectionsDir := filepath.Join(rootDir, "resume", "_sections")

	dataFiles, err := filepath.Glob(filepath.Join(sectionsDir, "*.tex"))
	if err != nil {
		t.Fatalf("Failed to glob section files: %v", err)
	}
	if len(dataFiles) == 0 {
		t.Skip("No section data files found")
	}

	datePattern := regexp.MustCompile(`\b(19|20)\d{2}\s*(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)[a-z]*\s*-\s*(19|20)\d{2}\s*(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)[a-z]*|present\b`)

	for _, path := range dataFiles {
		data, err := os.ReadFile(path)
		if err != nil {
			t.Errorf("Cannot read %s: %v", path, err)
			continue
		}

		// Check that dates follow expected format (YYYY Month - YYYY Month or "present")
		lines := strings.Split(string(data), "\n")
		for lineNum, line := range lines {
			trimmed := strings.TrimSpace(line)
			if trimmed == "" || strings.HasPrefix(trimmed, "%") {
				continue
			}

			// If the line looks like it contains a date but doesn't match pattern
			dateCandidateRegex := regexp.MustCompile(`\b(19|20)\d{2}\b.*-\s*(19|20)\d{2}\b`)
			if dateCandidateRegex.MatchString(trimmed) {
				if !datePattern.MatchString(trimmed) {
					t.Errorf("%s line %d: date range '%s' doesn't match expected format (YYYY Month - YYYY Month or present)", filepath.Base(path), lineNum+1, trimmed)
				}
			}
		}

		// Check for common LaTeX issues: unmatched braces
		openBraces := strings.Count(string(data), "{")
		closeBraces := strings.Count(string(data), "}")
		if openBraces != closeBraces {
			t.Errorf("%s has mismatched braces: %d opening vs %d closing", filepath.Base(path), openBraces, closeBraces)
		}
	}
}

// TestDataIncludes verifies that \input{} directives in section files
// resolve to existing sub-files (e.g., experience.tex including _entries/*.tex).
func TestDataIncludes(t *testing.T) {
	rootDir := ".."
	inputRegex := regexp.MustCompile(`\\input\{([^}]+)\}`)

	sectionsDir := filepath.Join(rootDir, "resume", "_sections")
	dataFiles, err := filepath.Glob(filepath.Join(sectionsDir, "*.tex"))
	if err != nil {
		t.Fatalf("Failed to glob section files: %v", err)
	}

	for _, path := range dataFiles {
		data, err := os.ReadFile(path)
		if err != nil {
			t.Errorf("Cannot read %s: %v", path, err)
			continue
		}

		dir := filepath.Dir(path)
		matches := inputRegex.FindAllStringSubmatch(string(data), -1)
		for _, m := range matches {
			target := strings.TrimSpace(m[1])
			candidates := []string{
				filepath.Join(dir, target),
				filepath.Join(dir, target+".tex"),
				filepath.Join(rootDir, target),
				filepath.Join(rootDir, target+".tex"),
			}

			found := false
			for _, c := range candidates {
				if _, err := os.Stat(c); err == nil {
					found = true
					break
				}
			}
			if !found {
				t.Errorf("Broken data include in %s: '%s' not found", filepath.Base(path), target)
			}
		}
	}
}
