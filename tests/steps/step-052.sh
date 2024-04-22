#!/usr/bin/env bash
# Test:
#   Cli tool: print help and usage

TEST_DIR=$(cd "$(dirname "$0")/.." && pwd)
# shellcheck disable=SC1091
. "$TEST_DIR/general.sh"

init_step

accept_all_trust_prompts || exit 1

"$GH_TEST_BIN/githooks-cli" installer "${EXTRA_INSTALL_ARGS[@]}" || exit 1

if ! "$GH_TEST_BIN/githooks-cli" --help | grep -q "See further information at"; then
    echo "! Unexpected cli help output"
    exit 1
fi
