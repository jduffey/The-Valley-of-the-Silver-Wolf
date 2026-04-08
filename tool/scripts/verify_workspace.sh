#!/usr/bin/env bash

set -euo pipefail

if ! command -v flutter >/dev/null 2>&1; then
  if [ -x "${HOME}/sdk/flutter/bin/flutter" ]; then
    export PATH="${HOME}/sdk/flutter/bin:${HOME}/.pub-cache/bin:${PATH}"
  fi
fi

if ! command -v melos >/dev/null 2>&1; then
  export PATH="${HOME}/.pub-cache/bin:${PATH}"
fi

command -v flutter >/dev/null 2>&1 || {
  echo "flutter is required to verify this workspace." >&2
  exit 1
}

command -v melos >/dev/null 2>&1 || {
  echo "melos is required to verify this workspace." >&2
  exit 1
}

melos bootstrap
melos run format
melos run analyze
melos run test
