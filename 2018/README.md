# BARR-C:2018 Enforcement Kit

Machine-enforceable configuration for Barr Group's Embedded C Coding
Standard, BARR-C:2018 (https://barrgroup.com/embedded-c-coding-standard).

Drop these files into your repository root:

| File | Purpose |
|---|---|
| `.clang-format` | The formatter config for the standard's white-space, brace, and line rules (clang-format 16+). Validated against the book's own examples. |
| `.editorconfig` | Editor-level line endings, indentation, and charset. |
| `.clang-tidy` | Static-analysis mapping of the decidable correctness rules (clang-tidy 17+). |
| `COMPILER_FLAGS.md` | The compiler warning gates for rules tools cannot express. |
| `check.sh` | One-command local/CI conformance check. |
| `ci/github-actions.yml` | Ready-made CI job. |
| `CLAUDE_BARRC.md` | Context file for AI code generators; commit at repo root. |
| `CODE_GENERATION_POLICY.md` | The 2026 edition's generated-code rules as adoptable policy. |
| `errata_2018.html` | Errata for the printed 2018 edition. |
| `COVERAGE_2018.md` | Per-rule map of all 167 rules to their enforcement mechanisms (or code review). |
| `coverage_2018.json` | The same coverage map, machine-readable. |

Known limits, stated plainly: Rule 8.3.a (break aligned with its case label)
is outside clang-format's expressive range; volatile discipline, ISR rules,
and cast commentary are review-and-flags territory (see COMPILER_FLAGS.md).

(c) 2026 Barr Group. These configuration files may be freely copied into
any project that adopts the BARR-C coding standard.
