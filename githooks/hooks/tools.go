package hooks

import (
	"path"
	cm "rycus86/githooks/common"
)

// GetToolsDir returns the tools directory of Githooks.
func GetToolsDir(installDir string) string {
	return path.Join(installDir, "tools")
}

// GetToolDir returns the specific tool directory of Githooks.
func GetToolDir(installDir string, tool string) string {
	return path.Join(GetToolsDir(installDir), tool)
}

// GetToolScript gets the tool script associated with the name `tool`.
func GetToolScript(installDir string, tool string) (cm.IExecutable, error) {

	tool = path.Join(GetToolDir(installDir, tool), "run")
	exists, _ := cm.IsPathExisting(tool)
	if !exists {
		return nil, nil
	}

	runCmd, err := GetToolRunCmd(tool)

	return &cm.Executable{Path: tool, RunCmd: runCmd}, err
}

// GetToolRunCmd gets the command string for the tool `toolPath`.
// It returns the command arguments which is `nil` if its an executable.
func GetToolRunCmd(toolPath string) ([]string, error) {
	return GetHookRunCmd(toolPath)
}