package resumescan

import (
	"os"
	"path/filepath"
	"regexp"
	"strings"
	"testing"
)

// TestSchemaDateRanges validates that multi-line \newdate blocks have consistent
// date formatting and balanced open/close markers (e.g. "present").
func TestSchemaDateRanges(t *testing.T) {
	rootDir := ".."
	texPath := filepath.Join(rootDir, "resume", "resume.tex")

	data, err := os.ReadFile(texPath)
	if err != nil {
		t.Fatalf("Failed to read %s: %v", texPath, err)
	}
	content := string(data)

	// Match multi-line \newdate{...}{start-date}{end-date} blocks.
	// These can span multiple lines due to LaTeX comments or formatting.
	newdateRegex := regexp.MustCompile(`\\newdate\s*\{\s*([^}]+)\}\s*\{\s*(.*?)\}\s*\{\s*(.*?)\s*\}`)

	matches := newdateRegex.FindAllStringSubmatch(content, -1)
	if len(matches) == 0 {
		t.Skip("No \\newdate blocks found in resume.tex")
	}

	openDatePattern := regexp.MustCompile(`^\d{4}-\d{2}-\d{2}$|^\s*(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)[a-z]* [12]\d{3}`)
	closeDatePattern := regexp.MustCompile(`^\d{4}-\d{2}-\d{2}$|^\s*(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)[a-z]* [12]\d{3}$|^\s*present\s*$`)

	for i, m := range matches {
		name := strings.TrimSpace(m[1])
		startRaw := strings.TrimSpace(m[2])
		endRaw := strings.TrimSpace(m[3])

		if !openDatePattern.MatchString(startRaw) {
			t.Errorf("Line %d: start date for \\\\newdate{%s} is malformed: %q", i+1, name, startRaw)
		}

		if !closeDatePattern.MatchString(endRaw) && endRaw != "present" {
			t.Errorf("Line %d: close date for \\\\newdate{%s} is malformed or missing 'present': %q", i+1, name, endRaw)
		}
	}
}

// TestSchemaPaleShadowHandles audits every pale-shadow handle in the resume
// against a known-good list of handles to catch stale or forgotten ones.
func TestSchemaPaleShadowHandles(t *testing.T) {
	rootDir := ".."
	texPath := filepath.Join(rootDir, "resume", "resume.tex")

	data, err := os.ReadFile(texPath)
	if err != nil {
		t.Fatalf("Failed to read %s: %v", texPath, err)
	}
	content := string(data)

	// pale-shadow handles appear as \paleShadow{name}{content} or inline.
	paleRegex := regexp.MustCompile(`\\paleShadow\s*\{\s*([^}]+)\}`)
	matches := paleRegex.FindAllStringSubmatch(content, -1)

	if len(matches) == 0 {
		t.Skip("No \\paleShadow handles found in resume.tex")
	}

	// Known valid pale-shadow handles; update when new ones are introduced.
	validHandles := map[string]bool{
		"linkedin":      true,
		"github":        true,
		"twitter":       true,
		"email":         true,
		"phone":         true,
		"location":      true,
		"personal-site": true,
	}

	for i, m := range matches {
		handle := strings.TrimSpace(m[1])
		if !validHandles[handle] {
			t.Errorf("Stale or unknown \\paleShadow handle at line ~%d: %s", i+1, handle)
		}
	}
}

// TestSchemaFieldStructure validates that required schema fields are present in
// the resume .tex file with correct LaTeX structure. Uses line-by-line checking
// rather than a single boolean match.
func TestSchemaFieldStructure(t *testing.T) {
	rootDir := ".."
	texPath := filepath.Join(rootDir, "resume", "resume.tex")

	data, err := os.ReadFile(texPath)
	if err != nil {
		t.Fatalf("Failed to read %s: %v", texPath, err)
	}
	lines := strings.Split(string(data), "\n")

	requiredFields := []string{
		"fed-resume",     // document class / package
		"_header",        // author header include
		"experience",     // experience section header
		"education",      // education section header
	}

	for _, field := range requiredFields {
		found := false
		for _, line := range lines {
			trimmed := strings.TrimSpace(line)
			if strings.Contains(trimmed, field) {
				found = true
				break
			}
		}
		if !found {
			t.Errorf("Missing required field in resume.tex: %s", field)
		}
	}

	// Validate that \\begin{document} and \\end{document} exist.
	beginFound := false
	endFound := false
	for _, line := range lines {
		if strings.Contains(line, "\\begin{document}") {
			beginFound = true
		}
		if strings.Contains(line, "\\end{document}") {
			endFound = true
		}
	}
	if !beginFound {
		t.Error("Missing \\\\begin{document} in resume.tex")
	}
	if !endFound {
		t.Error("Missing \\\\end{document} in resume.tex")
	}

	// Validate that section headers use \\section or similar.
	sectionPattern := regexp.MustCompile(`\\(?:sub)?section\s*\{`)
	for lineNum, line := range lines {
		if strings.Contains(line, "experience") || strings.Contains(line, "education") {
			if !sectionPattern.MatchString(line) && !strings.Contains(line, "\\input") {
				t.Errorf("Line %d: section-like content '%s' should use \\\\section or be \\\\input", lineNum+1, strings.TrimSpace(line))
			}
		}
	}
}

// TestSchemaDateConsistency checks that \\newdate definitions used by entries
// actually reference defined date ranges — no dangling \today or undefined refs.
func TestSchemaDateConsistency(t *testing.T) {
	rootDir := ".."
	texPath := filepath.Join(rootDir, "resume", "resume.tex")

	data, err := os.ReadFile(texPath)
	if err != nil {
		t.Fatalf("Failed to read %s: %v", texPath, err)
	}
	content := string(data)

	// Collect all defined date names from \\newdate{<name>}{...}{...}.
	definedRegex := regexp.MustCompile(`\\newdate\s*\{\s*([^}]+)\}`)
	defined := make(map[string]bool)
	for _, m := range definedRegex.FindAllStringSubmatch(content, -1) {
		defined[strings.TrimSpace(m[1])] = true
	}

	// Find all \\thedate{<name>} usage.
	thedateRegex := regexp.MustCompile(`\\thedate\s*\{\s*([^}]+)\}`)
	for _, m := range thedateRegex.FindAllStringSubmatch(content, -1) {
		name := strings.TrimSpace(m[1])
		if !defined[name] {
			t.Errorf("Undefined date name \\\\thedate{%s} referenced but never \\\\newdate'd", name)
		}
	}
}
