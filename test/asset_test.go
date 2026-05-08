package test

import (
	"os"
	"path/filepath"
	"strings"
	"testing"
)

func TestBiographyIntegrity(t *testing.T) {
	// Paths relative to the test directory
	biographyPaths := []string{
		"../resume/sections/biography.tex",
		"../resume/sections/objective.tex",
	}

	var bioFile string
	// Locate which file is being used as the biography/objective
	for _, path := range biographyPaths {
		if _, err := os.Stat(path); err == nil {
			bioFile = path
			break
		}
	}

	if bioFile == "" {
		t.Fatalf("Biography file not found. Checked: %v", biographyPaths)
	}

	// 1. Verify File Permissions (DevSecOps Hardening)
	t.Run("FilePermissions", func(t *testing.T) {
		info, err := os.Stat(bioFile)
		if err != nil {
			t.Fatalf("Failed to stat biography file: %v", err)
		}

		mode := info.Mode().Perm()
		// Secure standard: 0644 (-rw-r--r--)
		if mode != 0644 {
			t.Errorf("Security Risk: %s has permissive permissions: %s (expected -rw-r--r-- / 0644)", bioFile, mode)
		}
	})

	// 2. Scan Biography Content for Placeholders or Draft Notes
	t.Run("DraftPlaceholderScan", func(t *testing.T) {
		content, err := os.ReadFile(bioFile)
		if err != nil {
			t.Fatalf("Failed to read biography file: %v", err)
		}

		bioText := string(content)
		if len(strings.TrimSpace(bioText)) == 0 {
			t.Error("Biography file is empty!")
		}

		// List of forbidden placeholders in production-ready resume files
		forbiddenWords := []string{"TODO", "FIXME", "INSERT HERE", "LOREM IPSUM", "PLACEHOLDER"}

		for _, word := range forbiddenWords {
			if strings.Contains(strings.ToUpper(bioText), word) {
				t.Errorf("Draft content found: Biography contains placeholder token %q", word)
			}
		}
	})

	// 3. Verify LaTeX Input Reference
	t.Run("VerifyMainResumeIntegration", func(t *testing.T) {
		mainResumePath := "../resume/resume.tex"
		content, err := os.ReadFile(mainResumePath)
		if err != nil {
			t.Fatalf("Failed to read main resume.tex: %v", err)
		}

		resumeText := string(content)
		baseName := filepath.Base(bioFile)
		sectionName := strings.TrimSuffix(baseName, ".tex")

		// Search for \input{sections/biography} or \input{sections/objective}
		inputPattern := `\input{sections/` + sectionName + `}`
		if !strings.Contains(resumeText, inputPattern) {
			t.Logf("Warning: %s is not actively included in your resume.tex via %s. Ensure it isn't accidentally commented out.", bioFile, inputPattern)
		}
	})
}