#!/bin/sh
# BARR-C:2018 conformance check (format + static analysis + lexical gates)
# Usage: ./check.sh [files...]   (defaults to all tracked .c/.h files)
# Escape hatch: a source line whose // comment contains barr-c:allow is
# exempt from the lexical gates (reviewed exceptions only).
set -e
if [ "$#" -gt 0 ]; then
    FILES=$(printf '%s\n' "$@")
else
    FILES=$(git ls-files '*.c' '*.h' 2>/dev/null || find . -name '*.c' -o -name '*.h')
fi
[ -z "$FILES" ] && { echo "no C sources found"; exit 0; }
# newline-only word splitting so paths containing spaces survive expansion
IFS='
'

echo "== character and module gates (BARR-C:2018) =="
# Non-printing characters (Rules 3.5.a, 3.6.a, 3.6.b): LF ends lines and
# form feed is the only other permitted non-printable; tabs and CR are
# violations. The class is built at run time so this script itself never
# contains a control byte.
CTRL=$(printf '\001\002\003\004\005\006\007\010\011\013\015\016\017\020\021\022\023\024\025\026\027\030\031\032\033\034\035\036\037\177')
if grep -n "[$CTRL]" /dev/null $FILES; then
    echo "FAIL: control characters found (BARR-C 3.5.a tabs / 3.6.a CR line endings / 3.6.b non-printables)"
    exit 1
fi

# Module naming (Rules 4.1.a-4.1.d): lowercase names, unique in their
# first 8 characters, no standard-library header collisions, and main()
# lives in a module named main-something.
STDHDRS="assert.h complex.h ctype.h errno.h fenv.h float.h inttypes.h iso646.h limits.h locale.h math.h setjmp.h signal.h stdalign.h stdarg.h stdatomic.h stdbool.h stdckdint.h stddef.h stdint.h stdio.h stdlib.h stdnoreturn.h string.h tgmath.h threads.h time.h uchar.h wchar.h wctype.h"
NAMEBAD=0
for f in $FILES; do
    b=$(basename "$f")
    case "$b" in
        *[!a-z0-9_.]*)
            echo "FAIL: $b is not all lowercase (BARR-C 4.1.a)"
            NAMEBAD=1 ;;
    esac
    # substring match rather than a split loop: IFS is newline-only here
    case " $STDHDRS " in
        *" $b "*)
            echo "FAIL: $b collides with a standard library header (BARR-C 4.1.c)"
            NAMEBAD=1 ;;
    esac
    if grep -E '(^|[^A-Za-z0-9_])main[[:space:]]*\(' "$f" >/dev/null 2>&1; then
        case "$b" in
            *main*) : ;;
            *)
                echo "FAIL: $f defines main() but its name lacks the word main (BARR-C 4.1.d)"
                NAMEBAD=1 ;;
        esac
    fi
done
DUPSTEMS=$(for f in $FILES; do basename "$f" | sed 's/\.[ch]$//'; done \
           | sort -u | cut -c1-8 | sort | uniq -d)
if [ -n "$DUPSTEMS" ]; then
    echo "FAIL: module names not unique in their first 8 characters ($DUPSTEMS) (BARR-C 4.1.b)"
    NAMEBAD=1
fi
[ "$NAMEBAD" -eq 0 ] || exit 1

echo "== clang-format check (BARR-C:2018) =="
clang-format --style=file --dry-run --Werror $FILES

echo "== lexical gates (BARR-C:2018) =="
# Rule 5.2.b: the keywords short and long shall not be used.
# Patterns use explicit character classes, portable to BSD and GNU grep
# (never backslash-b or backslash-s, which are GNU extensions). Listing
# /dev/null first guarantees file:line: prefixes for any file count.
if grep -nE '(^|[^A-Za-z0-9_])(short|long)([^A-Za-z0-9_]|$)' /dev/null $FILES \
    | grep -v '//.*barr-c:allow' \
    | grep -vE '^[^:]*:[0-9]+:[[:space:]]*//'
then
    echo "FAIL: short/long keywords found (BARR-C 5.2.b); mark reviewed exceptions with // barr-c:allow"
    exit 1
fi
# Rules 1.7.a / 1.7.b: the auto and register keywords shall not be used.
if grep -nE '(^|[^A-Za-z0-9_])(auto|register)([^A-Za-z0-9_]|$)' /dev/null $FILES \
    | grep -v '//.*barr-c:allow' \
    | grep -vE '^[^:]*:[0-9]+:[[:space:]]*//'
then
    echo "FAIL: auto/register keywords found (BARR-C 1.7.a/1.7.b); mark reviewed exceptions with // barr-c:allow"
    exit 1
fi
# Rule 8.5.b: abort(), exit(), setjmp(), and longjmp() shall not be used.
if grep -nE '(^|[^A-Za-z0-9_])(abort|exit|setjmp|longjmp)[[:space:]]*\(' /dev/null $FILES \
    | grep -v '//.*barr-c:allow' \
    | grep -vE '^[^:]*:[0-9]+:[[:space:]]*//'
then
    echo "FAIL: abort/exit/setjmp/longjmp calls found (BARR-C 8.5.b); mark reviewed exceptions with // barr-c:allow"
    exit 1
fi
# Rule 1.7.c: goto is a preferred-practice avoidance; advisory only.
grep -nE '(^|[^A-Za-z0-9_])goto([^A-Za-z0-9_]|$)' /dev/null $FILES \
    | grep -v '//.*barr-c:allow' \
    && echo "ADVISORY: goto found (BARR-C 1.7.c prefers avoidance); review required" || true

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
