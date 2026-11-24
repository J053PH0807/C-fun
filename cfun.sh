#!/usr/bin/env bash
set -e

usage() {
    printf 'Usage: %s [run] FILE.c\n' "${0##*/}"
}

if [[ $# -eq 1 && $1 == --help ]]; then
    usage
    exit 0
fi

run=false
if [[ $1 == run ]]; then
    run=true
    shift
fi

if [[ $# -ne 1 || $1 != *.c ]]; then
    usage >&2
    exit 2
fi

source_file=$1
[[ $source_file == /* ]] || source_file=./$source_file
if [[ ! -f $source_file || ! -r $source_file ]]; then
    printf 'Cannot read source file: %s\n' "$1" >&2
    exit 1
fi

flags=()
IFS= read -r first_line < "$source_file" || true
if [[ $first_line == '// cfun: '* ]]; then
    read -r -a packages <<< "${first_line#// cfun: }"
    if [[ ${#packages[@]} -gt 0 ]]; then
        if ! command -v pkg-config >/dev/null 2>&1; then
            printf 'Install pkg-config to build %s.\n' "$1" >&2
            exit 1
        fi
        package_flags=$(pkg-config --cflags --libs -- "${packages[@]}")
        read -r -a flags <<< "$package_flags"
    fi
fi

repo_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
name=${source_file##*/}
output=$repo_dir/build/${name%.c}
mkdir -p -- "$repo_dir/build"
"${CC:-cc}" -std=c17 -Wall -Wextra -Wpedantic "$source_file" "${flags[@]}" -o "$output"

if [[ $run == true ]]; then
    exec "$output"
fi
