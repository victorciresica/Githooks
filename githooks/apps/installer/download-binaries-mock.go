// +build mock

package main

import (
	cm "gabyx/githooks/common"
	strs "gabyx/githooks/strings"
	"gabyx/githooks/updates"
	"gabyx/githooks/updates/download"
	"os"
	"path"
	"runtime"
)

// detectDeploySettings tries to detect the deploy settings.
// Currently that works for Github automatically.
// For Gitea you need to specify the deploy api `deployAPI`.
// Others will fail and need a special deploy settings config file.
func detectDeploySettings(cloneUrl string, deployAPI string) (download.IDeploySettings, error) {
	return nil, nil
}

func downloadBinaries(
	log cm.ILogContext,
	deploySettings download.IDeploySettings,
	tempDir string,
	versionTag string) updates.Binaries {

	bin := os.Getenv("GH_TEST_BIN")
	cm.PanicIf(strs.IsEmpty(bin), "GH_TEST_BIN undefined")

	log.InfoF("Faking download: taking from '%s'.", bin)

	ext := ""
	if runtime.GOOS == cm.WindowsOsName {
		ext = cm.WindowsExecutableSuffix
	}

	all := []string{
		path.Join(tempDir, "installer"+ext),
		path.Join(tempDir, "uninstaller"+ext),
		path.Join(tempDir, "cli"+ext),
		path.Join(tempDir, "runner"+ext)}

	for _, exe := range all {
		src := path.Join(bin, path.Base(exe))
		err := cm.CopyFile(src, exe)
		cm.AssertNoErrorPanicF(err, "Copy from '%s' to '%s' failed.", src, exe)
	}

	return updates.Binaries{All: all, Installer: all[0], Others: all[1:]}
}
