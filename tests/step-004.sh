#!/bin/sh
# Test:
#   Set up local repos, run the install and verify the hooks get installed

if echo "$EXTRA_INSTALL_ARGS" | grep -q "use-core-hookspath"; then
    echo "Using core.hooksPath"
    exit 249
fi

mkdir -p /tmp/test4/p001 && mkdir -p /tmp/test4/p002 || exit 1

cd /tmp/test4/p001 && git init || exit 1
cd /tmp/test4/p002 && git init || exit 1

if grep -r 'github.com/rycus86/githooks' /tmp/test4/; then
    echo "! Hooks were installed ahead of time"
    exit 1
fi

# run the install, and select installing the hooks into existing repos
echo 'n
y
/tmp/test4
' | "$GITHOOKS_BIN_DIR/installer" --stdin || exit 1

if ! grep -r 'github.com/rycus86/githooks' /tmp/test4/p001/.git/hooks; then
    echo "! Hooks were not installed successfully"
    exit 1
fi

if ! grep -r 'github.com/rycus86/githooks' /tmp/test4/p002/.git/hooks; then
    echo "! Hooks were not installed successfully"
    exit 1
fi
