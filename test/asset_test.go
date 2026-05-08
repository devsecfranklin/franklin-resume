package test

import (
	"os"
	"path/filepath"
	"strings"
	"testing"
)

func TestResumeSecurity(t *testing.T) {
	// Define required assets and their expected permissions
	requiredFiles := []struct {
		name     string
		path     string
		permMask os.FileMode // Expected permission (e.g., 0644)
	}{
		{"QR Code", "../resume/images/resume_qr.png", 0644},
		{"Headshot", "../resume/images/headshot2.jpg", 0644},
		{"Main LaTeX", "../resume/resume.tex", 0644},
	}

	// 1. Asset Existence & Permissions Check
	t.Run("FileIntegrity", func(t *testing.T) {
		for _, f := range requiredFiles {
			info, err := os.Stat(f.path)
			if os.IsNotExist(err) {
				t.Errorf("Critical file missing: %s", f.path)
				continue
			}

			// Check for over-permissive files (Security Check)
			if info.Mode().Perm() > f.permMask {
				t.Errorf("Security Risk: %s has permissive permissions: %v (expected %v)", 
					f.path, info.Mode().Perm(), f.permMask)
			}
		}
	})

	// 2. Sensitive Data Scan (Placeholder Check)
	t.Run("SensitiveContentScan", func(t *testing.T) {
		// Placeholders that should NOT be in your final resume
		forbiddenPatterns := []string{"TODO", "FIXME", "REDACTED", "XXX"}
		
		sectionsDir := "../resume/sections/"
		files, _ := os.ReadDir(sectionsDir)

		for _, file := range files {
			if filepath.Ext(file.Name()) == ".tex" {
				content, _ := os.ReadFile(filepath.Join(sectionsDir, file.Name()))
				
				for _, pattern := range forbiddenPatterns {
					if strings.Contains(strings.ToUpper(string(content)), pattern) {
						t.Errorf("Placeholder found in %s: '%s' must be resolved", file.Name(), pattern)
					}
				}
			}
		}
	})
}