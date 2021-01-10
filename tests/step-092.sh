#!/bin/sh
# Test:
#   Cli tool: manage global shared hook repository configuration

if ! "$GITHOOKS_BIN_DIR/installer" --stdin; then
    echo "! Failed to execute the install script"
    exit 1
fi

! "$GITHOOKS_EXE_GIT_HOOKS" config shared || exit 1
! "$GITHOOKS_EXE_GIT_HOOKS" config shared --add || exit 1
! "$GITHOOKS_EXE_GIT_HOOKS" config shared --local --add "asd" || exit 1

mkdir -p /tmp/test092 && cd /tmp/test092 && git init || exit 2

! "$GITHOOKS_EXE_GIT_HOOKS" config shared --local --add "" || exit 3
! "$GITHOOKS_EXE_GIT_HOOKS" config shared --global --local --add "a" "b" || exit 3
! "$GITHOOKS_EXE_GIT_HOOKS" config shared --local --print --add "a" "b" || exit 3

"$GITHOOKS_EXE_GIT_HOOKS" config shared --add "file:///tmp/test/repo1.git" "file:///tmp/test/repo2.git" || exit 4
"$GITHOOKS_EXE_GIT_HOOKS" config shared --global --print | grep -q 'test/repo1' || exit 5
"$GITHOOKS_EXE_GIT_HOOKS" config shared --global --print | grep -q 'test/repo2' || exit 6
! "$GITHOOKS_EXE_GIT_HOOKS" config shared --local --print | grep -q 'test/repo' || exit 7

"$GITHOOKS_EXE_GIT_HOOKS" config shared --local --add "file:///tmp/test/repo3.git" || exit 8
! "$GITHOOKS_EXE_GIT_HOOKS" config shared --global --print | grep -q 'test/repo3' || exit 9
"$GITHOOKS_EXE_GIT_HOOKS" config shared --local --print | grep -q 'test/repo3' || exit 10
"$GITHOOKS_EXE_GIT_HOOKS" config shared --print | grep -q 'test/repo1' || exit 11
"$GITHOOKS_EXE_GIT_HOOKS" config shared --print | grep -q 'test/repo2' || exit 12
"$GITHOOKS_EXE_GIT_HOOKS" config shared --print | grep -q 'test/repo3' || exit 13

"$GITHOOKS_EXE_GIT_HOOKS" config shared --reset &&
    "$GITHOOKS_EXE_GIT_HOOKS" config shared --print | grep -q -i 'none' || exit 14
