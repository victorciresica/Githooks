#!/usr/bin/env bash
# shellcheck disable=SC1091

set -e
set -u

ROOT_DIR=$(git rev-parse --show-toplevel)
. "$ROOT_DIR/tests/general.sh"

cd "$ROOT_DIR"

# shellcheck disable=SC2317
function clean_up() {
    docker rmi "githooks:test-rules" &>/dev/null || true
    docker volume rm gh-test-tmp &>/dev/null || true
}

trap clean_up EXIT

clean_up

# Build container to only copy to volumes.
cat <<EOF | docker build \
    --force-rm -t "githooks:volumecopy" -f - . || exit 1
    FROM scratch
    CMD you-should-not-run-this-container
EOF

# Build test container.
cat <<EOF | docker build --force-rm -t githooks:test-rules -
FROM golang:1.22-alpine
RUN apk update && apk add git git-lfs
RUN apk add bash jq curl docker just

RUN git config --global safe.directory /data

# CVE https://github.blog/2022-10-18-git-security-vulnerabilities-announced/#cve-2022-39253
RUN git config --system protocol.file.allow always

RUN curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b \$(go env GOPATH)/bin v1.59.0

RUN git config --global user.email "githook@test.com" && \
    git config --global user.name "Githook Tests" && \
    git config --global init.defaultBranch main && \
    git config --global core.autocrlf false

ENV DOCKER_RUNNING=true
EOF

# Create a volume where all test setup and repositories go in.
# Is mounted to `/tmp`
docker volume create gh-test-tmp

mountArg=":ro"
if [ "${GH_FIX:-}" = "true" ]; then
    mountArg=""
fi

docker run --rm -it \
    -v "$ROOT_DIR:/data$mountArg" \
    -v "gh-test-tmp:/tmp" \
    -v "/var/run/docker.sock:/var/run/docker.sock" \
    -e "GH_SHOW_DIFFS=${GH_SHOW_DIFFS:-false}" \
    -e "GH_FIX=${GH_FIX:-false}" \
    -w /data \
    githooks:test-rules tests/exec-rules.sh ||
    {
        echo "! Check rules had failures: exit code: $?"
        exit 1
    }
