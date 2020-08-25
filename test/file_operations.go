package test

import (
	"github.com/google/uuid"
	"github.com/otiai10/copy"
	"io/ioutil"
	"os"
	"path/filepath"
	"testing"
)

var terraformWorkingFilesGlob = []string{
	"/*.tfvars",
	"/*.tfstate*",
	"/.terraform",
	"/jx-requirements.yml",
}

func prepareTerraformDir(t *testing.T) string {
	dirName, err := ioutil.TempDir("", uuid.New().String())
	if err != nil {
		t.Fatalf("Failed to create temp dir %s", dirName)
	}

	err = copy.Copy("../jx_module", dirName)

	if err != nil {
		t.Fatalf("Failed to copy terraform module to temp dir %s", dirName)
	}

	for _, g := range terraformWorkingFilesGlob {
		removeGlobbedFiles(t, dirName, g)
	}

	return dirName
}

func removeGlobbedFiles(t *testing.T, dirName string, glob string) {
	files, err := filepath.Glob(dirName + glob)
	if err != nil {
		t.Fatal("Failed to create glob for removing")
	}
	for _, f := range files {
		if err := os.RemoveAll(f); err != nil {
			t.Fatalf("Failed to remove file %s from terraform directory", f)
		}
	}
}
