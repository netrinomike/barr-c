#!/bin/sh
# BARR-C:2018 conformance check (format + static analysis + lexical gates)
# Usage: ./check.sh [files...]   (defaults to all tracked .c/.h files)
set -e
FILES="$@"
if [ -z "$FILES" ]; then
    FILES=$(git ls-files '*.c' '*.h' 2>/dev/null || find . -name '*.c' -o -name '*.h')
fi
[ -z "$FILES" ] && { echo "no C sources found"; exit 0; }

echo "== clang-format check (BARR-C:2018) =="
clang-format --style=file --dry-run --Werror $FILES

echo "== lexical gates (BARR-C:2018) =="
# Rule 5.2.b: the keywords short and long shall not be used.
# Escape hatch for a reviewed exception: append a comment containing barr-c:allow
if grep -nE '(short|long)' $FILES | grep -v 'barr-c:allow' | grep -v '^\s*//' ; then
    echo "FAIL: short/long keywords found (BARR-C 5.2.b); mark reviewed exceptions with // barr-c:allow"
    exit 1
fi
# Rule 1.7.c: goto is a preferred-practice avoidance; advisory only.
grep -nE 'goto' $FILES | grep -v 'barr-c:allow'     && echo "ADVISORY: goto found (BARR-C 1.7.c prefers avoidance); review required" || true

echo "== clang-tidy check (BARR-C:2018) =="
# Works without a compilation database (compile flags after --). For real
# projects generate compile_commands.json (CMake: -DCMAKE_EXPORT_COMPILE_COMMANDS=ON).
# -x c forces C parsing for .h files, which clang-tidy otherwise treats as C++.
if [ -f compile_commands.json ]; then
    clang-tidy $FILES
else
    clang-tidy $FILES -- -x c -std=c99 -Wall
fi
echo "OK: BARR-C:2018 gates passed"
