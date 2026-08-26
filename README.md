# BARR-C — Enforcement Kits for the Embedded C Coding Standard

Machine-enforceable configuration for **BARR-C**, Barr Group's *Embedded C
Coding Standard* by Michael Barr, one of the most widely adopted coding
standards in embedded systems, harmonized with MISRA C.

- 📖 The standard (free PDF and online edition): **[barrgroup.com/embedded-c-coding-standard](https://barrgroup.com/embedded-c-coding-standard)**
- 🖨️ Printed edition: [available at Amazon](https://www.amazon.com/dp/1721127984)

## What this is

A coding standard that lives only in a PDF is a suggestion. This repository
makes BARR-C executable: formatter configuration, static-analysis mapping,
compiler gates, a one-command conformance check, ready-made CI, and a
context file that makes the standard binding on AI code generators.

## Kits

| Directory | Edition | Status |
|---|---|---|
| [`2018/`](2018/) | BARR-C:2018 (current printed edition) | **Available now** |
| `2026/` | BARR-C:2026 | Arriving with the 2026 edition, including the machine-readable rule manifest |

Each kit drops into a repository root:

| File | Purpose |
|---|---|
| `.clang-format` | The standard's white-space, brace, and line rules (clang-format 16+); validated against the book's own examples |
| `.editorconfig` | Editor-level line endings, indentation, charset |
| `.clang-tidy` | Static-analysis mapping of the decidable correctness rules (clang-tidy 17+); every listed check verified to operate on plain C |
| `COMPILER_FLAGS.md` | Warning gates for rules tools cannot express |
| `check.sh` | One-command conformance check (format + lexical gates + tidy) |
| `ci/github-actions.yml` | Ready-made CI job |
| `CLAUDE_BARRC.md` | Context file for AI code generators: commit it at your repo root and the standard becomes the generator's input |
| `CODE_GENERATION_POLICY.md` | Four adoptable rules for AI-generated and machine-generated code |

The 2018 kit additionally ships [`COVERAGE_2018.md`](2018/COVERAGE_2018.md):
a per-rule map of all 167 rules of BARR-C:2018 to the mechanism that
enforces each one (or an honest "code review"), including the analysis of
every rule covered by two or more tools and why no pair is contradictory.

## Validated, not just plausible

Enforcement configs that merely *look* right are how teams ship rules that
are checked exactly zero times. Every gate in these kits is proven by the
fixture suite in [`tests/`](tests/): one deliberate violation per mechanism,
each asserted to fail its mapped gate and pass all others, a fully
conforming pair that must pass everything, and a format round-trip proving
the tools never contradict each other. CI runs the suite
([kit-selftest](.github/workflows/selftest.yml)) on every push with
version-pinned tools. Never trust an enforcement tool you have not watched
fail.

## Errata

Known defects in the printed 2018 edition: [ERRATA_2018.md](ERRATA_2018.md).
Found something? **Open an issue**: this repository is the standard's
public errata and feedback channel.

## Honest limits

Not everything is machine-checkable, and this repo says so rather than
pretending: `break`-aligned-with-`case` layout (Rule 8.3.a) is outside
clang-format's range; `volatile` discipline, ISR rules, and cast commentary
are review territory. See each kit's README and `COMPILER_FLAGS.md`.

## License

The configuration files in this repository are MIT-licensed; copy them into
any project. The *Embedded C Coding Standard* text itself remains
copyrighted by Barr Group and is licensed separately (free PDF at the link
above).

---

*Barr Group's engineers wrote the standard, and serve as
[software expert witnesses](https://barrgroup.com/software-expert-witness/litigation-services)
in cases where code quality is on trial.*
