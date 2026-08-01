#!/bin/sh
# BARR-C enforcement kit validation suite.
#
# Usage: tests/run_tests.sh <kit-dir>        (e.g. tests/run_tests.sh 2018)
#
# Proves every gate the kit claims actually fires: each fixture in
# tests/fixtures/ plants exactly one violation and the mapped gate must fail
# on it (with the expected message) while every other gate passes, unless the
# manifest's allowed_extra column records a known multi-tool overlap. The
# clean pair must pass everything, and the format round-trip (clang-format -i
# then re-run all gates) proves the tools never contradict each other.
#
# Env overrides: CLANG_FORMAT, CLANG_TIDY, CC (default gcc; the
# cc_fallthrough fixture relies on gcc/clang both diagnosing an uncommented
# fall-through). Gates whose tool is absent are counted as SKIP, except the
# script gate, which stubs missing tools so the lexical logic always runs.
set -u

KIT_ARG=${1:?usage: run_tests.sh <kit-dir>}
HERE=$(cd "$(dirname "$0")" && pwd)
KIT=$(cd "$HERE/.." && cd "$KIT_ARG" 2>/dev/null && pwd) || KIT=$(cd "$KIT_ARG" && pwd)
FIX="$HERE/fixtures"
CLANG_FORMAT=${CLANG_FORMAT:-clang-format}
CLANG_TIDY=${CLANG_TIDY:-clang-tidy}
CC_BIN=${CC:-gcc}

PASS=0
FAILED=0
SKIP=0
note_fail() { echo "FAIL: $1"; FAILED=$((FAILED + 1)); }
note_pass() { PASS=$((PASS + 1)); }
have() { command -v "$1" >/dev/null 2>&1; }

echo "kit under test: $KIT"
have "$CLANG_FORMAT" && "$CLANG_FORMAT" --version | head -1
have "$CLANG_TIDY" && "$CLANG_TIDY" --version | sed -n 2p
have "$CC_BIN" && "$CC_BIN" --version | head -1

STD=$(sed -n 's/.*-std=\(c[0-9][0-9]\).*/\1/p' "$KIT/check.sh" | head -1)
[ -n "$STD" ] || { echo "cannot derive -std from $KIT/check.sh"; exit 1; }
echo "dialect pin: -std=$STD"

# Compiler flags come from the kit's COMPILER_FLAGS.md so the document stays
# the single source of truth; -std is applied from check.sh's pin instead.
CFLAGS=$(sed -n 's/^    \(-[A-Za-z0-9=_+-]*\).*/\1/p' "$KIT/COMPILER_FLAGS.md" \
         | grep -v '^-std=' | tr '\n' ' ')
echo "compiler gates: $CFLAGS"

# ---------- preflight: the kit files themselves ----------
for f in .clang-format .clang-tidy .editorconfig check.sh ci/github-actions.yml; do
    if LC_ALL=C grep -q '[^ -~	]' "$KIT/$f"; then
        note_fail "preflight: control or non-ASCII bytes in $f"
    else
        note_pass
    fi
done
if grep -F '\b' "$KIT/check.sh" >/dev/null || grep -F '\s' "$KIT/check.sh" >/dev/null; then
    note_fail "preflight: GNU-only regex atom (backslash-b or backslash-s) in check.sh"
else
    note_pass
fi
if grep -E '^[[:space:]]*run:.*check\.sh' "$KIT/ci/github-actions.yml" >/dev/null; then
    note_pass
else
    note_fail "preflight: CI workflow does not run check.sh (gates would diverge)"
fi

# ---------- tool shims for the script gate ----------
# check.sh invokes bare tool names; expose the configured tools under those
# names, or a pass-through stub when absent (so the lexical logic always runs).
STUB=$(mktemp -d)
shim() {
    if have "$2"; then
        ln -s "$(command -v "$2")" "$STUB/$1"
    else
        printf '#!/bin/sh\nexit 0\n' > "$STUB/$1"
        chmod +x "$STUB/$1"
        echo "note: $1 missing; script gate uses a pass-through stub for it"
    fi
}
shim clang-format "$CLANG_FORMAT"
shim clang-tidy "$CLANG_TIDY"

sandbox() {
    T=$(mktemp -d)
    cp "$KIT/.clang-format" "$KIT/.clang-tidy" "$T/"
    cp "$KIT/check.sh" "$T/check.sh"
    chmod +x "$T/check.sh"
}

gate_fmt()    { (cd "$T" && "$CLANG_FORMAT" --style=file --dry-run --Werror "$@" 2>&1); }
gate_tidy()   { (cd "$T" && "$CLANG_TIDY" "$@" -- -x c -std="$STD" -Wall 2>&1); }
gate_cc()     { (cd "$T" && "$CC_BIN" -c -o /dev/null -std="$STD" $CFLAGS -Werror "$@" 2>&1); }
gate_script() { (cd "$T" && PATH="$STUB:$PATH" sh ./check.sh "$@" 2>&1); }

# check_gate <fixture> <gate> <rc> <output> <expect> <match> <extras>
check_gate() {
    cg_fx=$1; cg_gate=$2; cg_rc=$3; cg_out=$4; cg_expect=$5; cg_match=$6; cg_extras=$7
    if [ "$cg_gate" = "$cg_expect" ]; then
        if [ "$cg_rc" -eq 0 ]; then
            note_fail "$cg_fx: $cg_gate gate did NOT fail (violation not caught)"
        elif [ "$cg_match" != "-" ] && ! printf '%s' "$cg_out" | grep -F "$cg_match" >/dev/null; then
            note_fail "$cg_fx: $cg_gate failed but without expected message '$cg_match'"
        else
            note_pass
        fi
    else
        case ",$cg_extras," in
            *",$cg_gate,"*)
                note_pass ;;  # documented overlap; failure permitted either way
            *)
                if [ "$cg_rc" -ne 0 ]; then
                    note_fail "$cg_fx: unexpected $cg_gate failure (undeclared overlap): $(printf '%s' "$cg_out" | head -3)"
                else
                    note_pass
                fi ;;
        esac
    fi
}

# ---------- fixture matrix ----------
grep -v '^#' "$HERE/manifest.tsv" | while IFS='	' read -r fx expect match extras; do
    [ -n "$fx" ] || continue
    sandbox
    # a fixture entry may be a comma-separated file set (multi-file gates
    # like the 4.1.b module-name uniqueness check)
    FXFILES=$(printf '%s' "$fx" | tr ',' ' ')
    for ff in $FXFILES; do
        cp "$FIX/$ff" "$T/"
    done

    case "$expect" in
        script-fail)
            out=$(gate_script $FXFILES); rc=$?
            if [ "$rc" -ne 0 ] && printf '%s' "$out" | grep -F "$match" >/dev/null; then
                echo "ok $fx (script gate failed as required)"
            else
                echo "MFAIL $fx: script gate rc=$rc missing '$match'"
            fi ;;
        script-advisory)
            out=$(gate_script $FXFILES); rc=$?
            if [ "$rc" -eq 0 ] && printf '%s' "$out" | grep -F "$match" >/dev/null; then
                echo "ok $fx (advisory printed, build not failed)"
            else
                echo "MFAIL $fx: rc=$rc or missing '$match'"
            fi ;;
        script-clean)
            out=$(gate_script $FXFILES); rc=$?
            if [ "$rc" -eq 0 ] && ! printf '%s' "$out" | grep -E 'FAIL|ADVISORY' >/dev/null; then
                echo "ok $fx (barr-c:allow escape honored)"
            else
                echo "MFAIL $fx: rc=$rc or unexpected FAIL/ADVISORY in output"
            fi ;;
        fmt|tidy|cc)
            for gate in fmt tidy cc; do
                case "$gate" in
                    fmt)  tool=$CLANG_FORMAT ;;
                    tidy) tool=$CLANG_TIDY ;;
                    cc)   tool=$CC_BIN ;;
                esac
                if ! have "$tool"; then
                    [ "$gate" = "$expect" ] && echo "skip $fx ($gate tool absent)"
                    continue
                fi
                case "$gate" in
                    fmt)  out=$(gate_fmt $FXFILES);  rc=$? ;;
                    tidy) out=$(gate_tidy $FXFILES); rc=$? ;;
                    cc)   out=$(gate_cc $FXFILES);   rc=$? ;;
                esac
                if [ "$gate" = "$expect" ]; then
                    if [ "$rc" -ne 0 ] && { [ "$match" = "-" ] || printf '%s' "$out" | grep -F "$match" >/dev/null; }; then
                        echo "ok $fx ($gate caught it)"
                    else
                        echo "MFAIL $fx: $gate rc=$rc, expected failure matching '$match'"
                        printf '%s\n' "$out" | head -4
                    fi
                else
                    case ",$extras," in
                        *",$gate,"*) : ;;
                        *) if [ "$rc" -ne 0 ]; then
                               echo "MFAIL $fx: undeclared $gate overlap"
                               printf '%s\n' "$out" | head -4
                           fi ;;
                    esac
                fi
            done ;;
        *)
            echo "MFAIL $fx: unknown expect '$expect'" ;;
    esac
    rm -rf "$T"
done > "$STUB/matrix.log" 2>&1
cat "$STUB/matrix.log"
MFAILS=$(grep -c '^MFAIL' "$STUB/matrix.log" || true)
MSKIPS=$(grep -c '^skip' "$STUB/matrix.log" || true)
MOKS=$(grep -c '^ok' "$STUB/matrix.log" || true)
PASS=$((PASS + MOKS))
FAILED=$((FAILED + MFAILS))
SKIP=$((SKIP + MSKIPS))

# ---------- clean pair must pass every gate ----------
sandbox
cp "$FIX/clean.c" "$FIX/clean.h" "$T/"
if have "$CLANG_FORMAT"; then
    out=$(gate_fmt clean.c clean.h) && note_pass \
        || note_fail "clean pair rejected by clang-format: $(printf '%s' "$out" | head -3)"
else SKIP=$((SKIP + 1)); fi
if have "$CLANG_TIDY"; then
    out=$(gate_tidy clean.c) && note_pass \
        || note_fail "clean.c rejected by clang-tidy: $(printf '%s' "$out" | head -3)"
    out=$(gate_tidy clean.h) && note_pass \
        || note_fail "clean.h rejected by clang-tidy: $(printf '%s' "$out" | head -3)"
else SKIP=$((SKIP + 2)); fi
out=$(gate_cc clean.c) && note_pass \
    || note_fail "clean.c rejected by compiler gates: $(printf '%s' "$out" | head -3)"
out=$(gate_script clean.c clean.h); rc=$?
if [ "$rc" -eq 0 ] && ! printf '%s' "$out" | grep -E 'FAIL|ADVISORY' >/dev/null; then
    note_pass
else
    note_fail "clean pair rejected by check.sh (word-boundary or comment-filter regression): $(printf '%s' "$out" | head -5)"
fi
rm -rf "$T"

# ---------- format round-trip: the no-deadlock proof ----------
if have "$CLANG_FORMAT"; then
    sandbox
    cp "$FIX/roundtrip_seed.c" "$T/"
    if gate_fmt roundtrip_seed.c >/dev/null 2>&1; then
        note_fail "roundtrip seed unexpectedly clean before formatting"
    else
        note_pass
    fi
    (cd "$T" && "$CLANG_FORMAT" --style=file -i roundtrip_seed.c)
    out=$(gate_fmt roundtrip_seed.c) && note_pass \
        || note_fail "roundtrip: formatter output rejected by formatter"
    if have "$CLANG_TIDY"; then
        out=$(gate_tidy roundtrip_seed.c) && note_pass \
            || note_fail "roundtrip CONTRADICTION: formatted code fails clang-tidy: $(printf '%s' "$out" | head -3)"
    else SKIP=$((SKIP + 1)); fi
    out=$(gate_cc roundtrip_seed.c) && note_pass \
        || note_fail "roundtrip CONTRADICTION: formatted code fails compiler gates"
    out=$(gate_script roundtrip_seed.c); rc=$?
    [ "$rc" -eq 0 ] && note_pass \
        || note_fail "roundtrip CONTRADICTION: formatted code fails check.sh"
    rm -rf "$T"
else
    SKIP=$((SKIP + 5))
fi

rm -rf "$STUB"
echo "-------------------------------------------"
echo "suite: $PASS passed, $FAILED failed, $SKIP skipped (tool absent)"
[ "$FAILED" -eq 0 ] || exit 1
echo "OK: every claimed gate has been watched to fail"
exit 0
