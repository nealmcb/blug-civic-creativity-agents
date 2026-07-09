#!/usr/bin/env bash
# Poll GitHub Pages build status until the given commit is built (or errors).
set -euo pipefail

REPO="nealmcb/blug-civic-creativity-agents"
TARGET="${1:?usage: watch-pages-build.sh <short-sha>}"

start=$(date +%s)
prev=""
while true; do
  out=$(gh api "repos/${REPO}/pages/builds/latest" 2>&1)
  commit=$(echo "$out" | grep -o '"commit":"[0-9a-f]*"' | cut -d'"' -f4 | cut -c1-7)
  status=$(echo "$out" | grep -o '"status":"[a-z]*"' | head -1 | cut -d'"' -f4)
  now=$(date +%s)
  elapsed=$((now - start))
  line="${elapsed}s commit=${commit} status=${status}"
  if [ "$line" != "$prev" ]; then
    echo "$line"
    prev="$line"
  fi
  if [ "$commit" = "$TARGET" ] && [ "$status" = "built" ]; then
    echo "DONE: build for $TARGET completed after ${elapsed}s"
    break
  fi
  if [ "$status" = "errored" ]; then
    echo "ERROR: build failed"
    echo "$out"
    break
  fi
  sleep 5
done
