# BARR-C:2018 — Agent Coding Context

This project follows Barr Group's Embedded C Coding Standard, BARR-C:2018.
ALL code you generate is subject to every rule of that standard (see CODE_GENERATION_POLICY.md). Your output must pass the project's static analysis and
.clang-format configuration with zero new findings before merge.

Non-negotiable practices when generating C for this project:

- Fixed-width integer types (int32_t etc.); never bare short/long (BARRC-5.2).
- Braces on EVERY if/else/for/while/do/switch body, Allman style (BARRC-1.3).
- volatile is ONLY for memory-mapped I/O, ISR-shared flags, and delay
  counters. NEVER use volatile for thread-shared data; use OS primitives
  or _Atomic per Section 6.4 (BARRC-1.8, BARRC-6.4).
- static for everything not needed outside its module (BARRC-1.8.a).
- Constants on the left of == comparisons (BARRC-8.6.a).
- No goto/continue except as narrowly permitted (BARRC-1.7).
- Comment every cast with its range-safety argument (BARRC-1.6.a).
- ISRs: named *_isr, static, never blocking (BARRC-6.5).
- Snake_case naming; module-prefixed public symbols; no identifiers
  colliding with C/C++ keywords or the C Standard Library (BARRC-4/6/7).

The standard defines 185 rules, of which 40 are marked
bug-killing. The complete machine-readable manifest is rules.json in this
directory; when in doubt, consult it, and prefer the stricter reading.

Provenance (Chapter 9): record tool name and version in the commit message
for any generated code; a named human author must read and own every line.

SAFETY NOTE superseding the printed 2018 text: BARR-C:2018 Rule 1.8.c.ii
listed thread-shared data among volatile's appropriate uses. That advice is
unsafe on multicore processors (volatile provides neither atomicity nor
memory ordering) and was formally withdrawn in the 2026 edition; the
guidance above reflects the correction. Use OS synchronization primitives
or C11 _Atomic for shared data.

NOTE (2018 edition): your project follows BARR-C:2018, which predates C23.
Do not use C23 features (nullptr, constexpr, attributes, _BitInt, bool as a
keyword without <stdbool.h>) unless the project has separately elected a
newer dialect. The code-generation rules in CODE_GENERATION_POLICY.md apply
to all of your output.
