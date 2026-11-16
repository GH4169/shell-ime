#!/usr/bin/env bash
set -euo pipefail
cd -- "$(dirname -- "$0")"
mkdir -p build
gcc -Wall -Wextra -Werror -O2 -o build/shell-ime-state src/state.c
printf 'Built Linux shell state helper. Windows Code renderer uses OSC 777.\n'
