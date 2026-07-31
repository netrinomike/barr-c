# BARR-C:2018 recommended compiler gates

The cheapest, most reliable enforcement is the compiler itself. These flags
implement rules that neither clang-format nor clang-tidy can.

## GCC / Clang

    # Rule 1.1: C99 baseline; pin it so the dialect cannot float with the
    # toolchain (newer GCC releases default to a GNU dialect of C23).
    -std=c99
    -Werror=implicit-function-declaration

    -Wall -Wextra
    -Werror=parentheses       # 8.6 suspicious assignment (note: an extra ()
                              # suppresses it by design; constant-on-the-left
                              # remains the primary defense)
    -Wfloat-equal             # 5.4.b.iv no float equality tests
    -Wsign-compare            # 5.3.c signed/unsigned mixing (in -Wall)
    -Wshadow
    -Wundef
    -Wswitch-default          # 8.3.b default required
    -Wimplicit-fallthrough    # 8.3.c commented fall-throughs
    -Wvla
