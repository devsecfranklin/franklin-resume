package resumescan

import (
	"os"
	"os/exec"
	"path/filepath"
	"regexp"
	"strings"
	"testing"
)

// TestLatexIncludeAndPackageIntegrity verifies that all \input{}, \include{},
// and custom local \usepackage{} directives resolve to actual files on disk.
func TestLatexIncludeAndPackageIntegrity(t *testing.T) {
	rootDir := ".."
	includeRegex := regexp.MustCompile(`\\(?:input|include)\{([^}]+)\}`)
	packageRegex := regexp.MustCompile(`\\usepackage(?:\[[^\]]*\])?\{([^}]+)\}`)

	// Custom local packages that must be present in the repository
	knownLocalPackages := map[string]bool{
		"fed-resume": true,
		"monserrat":  true, // Note single 't' matching repository file
	}

	err := filepath.Walk(rootDir, func(path string, info os.FileInfo, err error) error {
		if err != nil {
			return err
		}
		// Skip non-tex files, git directories, build caches, and the test fixture
		if info.IsDir() || filepath.Ext(path) != ".tex" || strings.Contains(path, "/test/test.tex") {
			return nil
		}
		if strings.Contains(path, "/autom4te.cache/") || strings.Contains(path, "/.git/") {
			return nil
		}

		data, err := os.ReadFile(path)
		if err != nil {
			t.Fatalf("Failed to read %s: %v", path, err)
		}
		content := string(data)
		dir := filepath.Dir(path)

		// 1. Validate \input{} and \include{}
		matches := includeRegex.FindAllStringSubmatch(content, -1)
		for _, m := range matches {
			target := strings.TrimSpace(m[1])

			// Try relative to current file directory, then relative to repo root
			candidates := []string{
				filepath.Join(dir, target),
				filepath.Join(dir, target+".tex"),
				filepath.Join(rootDir, target),
				filepath.Join(rootDir, target+".tex"),
			}

			found := false
			for _, candidate := range candidates {
				if _, err := os.Stat(candidate); err == nil {
					found = true
					break
				}
			}

			if !found {
				t.Errorf("Broken inclusion in %s: target '%s' not found", path, target)
			}
		}

		// 2. Validate custom local \usepackage{}
		pkgMatches := packageRegex.FindAllStringSubmatch(content, -1)
		for _, pm := range pkgMatches {
			pkgs := strings.Split(pm[1], ",")
			for _, pkg := range pkgs {
				pkgName := strings.TrimSpace(pkg)
				if knownLocalPackages[pkgName] {
					styName := pkgName + ".sty"
					styCandidates := []string{
						filepath.Join(dir, styName),
						filepath.Join(rootDir, "resume", styName),
						filepath.Join(rootDir, "biography", styName),
					}

					styFound := false
					for _, sc := range styCandidates {
						if _, err := os.Stat(sc); err == nil {
							styFound = true
							break
						}
					}
					if !styFound {
						t.Errorf("Missing local package in %s: %s not found on disk", path, styName)
					}
				}
			}
		}

		return nil
	})

	if err != nil {
		t.Fatalf("Walk failed: %v", err)
	}
}

// TestLatexCompilationSmoke runs a headless compilation against resume/resume.tex
func TestLatexCompilationSmoke(t *testing.T) {
	engine, err := exec.LookPath("xelatex")
	if err != nil {
		engine, err = exec.LookPath("pdflatex")
	}
	if err != nil {
		t.Skip("Neither pdflatex nor xelatex found on host, skipping smoke test")
	}

	target := filepath.Join("..", "resume", "resume.tex")
	if _, err := os.Stat(target); os.IsNotExist(err) {
		t.Skipf("Entrypoint %s does not exist", target)
	}

	tmpDir := t.TempDir()
	absTarget, err := filepath.Abs(target)
	if err != nil {
		t.Fatalf("Failed to resolve target: %v", err)
	}
	cmd := exec.Command(engine, "-interaction=nonstopmode", "-shell-escape", "-output-directory="+tmpDir, absTarget)
	cmd.Dir = filepath.Dir(absTarget)
	out, err := cmd.CombinedOutput()
	if err != nil {
		t.Fatalf("LaTeX compilation failed: %v\nOutput snippet:\n%s", err, string(out))
	}
}
