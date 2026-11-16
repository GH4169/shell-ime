#!/usr/bin/env bash
set -euo pipefail
root_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
bash "$root_dir/build.sh"
bash "$root_dir/package.sh"
printf 'Source shell/bash.sh or shell/zsh.sh from the corresponding interactive shell.\n'
printf 'Install the VSIX on the Code UI host; apply patch-code.js after editor-ime-mode when building a matching user runtime.\n'
