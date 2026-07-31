# Code Generation and Provenance Policy (BARR-C)

BARR-C:2018 predates AI code generation. These four rules are the corresponding chapter of the forthcoming 2026 edition, offered as ready-to-adopt project policy for teams remaining on BARR-C:2018.

1. **Generated code is code.** Code produced wholly or partly by an automated
   generator (including AI coding assistants and agents) is subject to every
   rule of the coding standard, without exception or relaxation.

2. **Named accountability.** Every commit containing generated code shall
   identify a human author who has read the code in full and accepts
   responsibility for it. Review by the generating tool, however
   sophisticated, is not review.

3. **Provenance recorded.** The commit message or a file-header comment shall
   record the generating tool and its version. The full prompt or
   configuration need not be recorded, but the fact of generation shall be.

4. **Static analysis is the gate.** Generated code shall pass the project's
   static-analysis configuration with zero new findings before merge, and
   human review of generated code shall be at least as rigorous as review of
   hand-written code.

The `CLAUDE_BARRC.md` file in this kit expresses the coding standard as
context for AI code generators; committing it to the repository root is the
practical implementation of making the standard the generator's input.
