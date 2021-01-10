#!/bin/sh
# Test:
#   Direct template execution: ignoring some hooks

mkdir -p /tmp/test15 && cd /tmp/test15 || exit 1
git init || exit 1

mkdir -p .githooks/pre-commit &&
    echo 'exit 1' >.githooks/pre-commit/test.first &&
    echo 'exit 1' >.githooks/pre-commit/test.second &&
    echo 'echo "Third was run" >> /tmp/test015.out' >.githooks/pre-commit/test.third &&
    echo '#!/bin/sh' >.githooks/pre-commit/test.fourth &&
    echo 'echo "Fourth was run" >> /tmp/test015.out ' >>.githooks/pre-commit/test.fourth &&
    chmod +x .githooks/pre-commit/test.fourth &&
    echo 'patterns: - pre-commit/*first' >.githooks/.ignore.yaml &&
    echo 'patterns: - pre-commit/*second' >.githooks/pre-commit/.ignore.yaml &&
    "$GITHOOKS_BIN_DIR/runner" "$(pwd)"/.git/hooks/pre-commit ||
    exit 1

grep -q 'Third was run' /tmp/test015.out &&
    grep -q 'Fourth was run' /tmp/test015.out ||
    exit 1
