# BARR-C:2018 Errata

Defects identified in the published BARR-C:2018 edition. All are corrected
in the forthcoming BARR-C:2026 edition; teams using the 2018 book should
apply these corrections when adopting the affected rules.

| Location | Defect | Correction |
|---|---|---|
| Rule 5.4.b.i | Instructs use of "C99 type names" `float32_t`, `float64_t`, `float128_t`; C99 defines no such types (they are CMSIS-DSP conventions). | The standardized names are `_Float32`/`_Float64`/`_Float128` (ISO/IEC TS 18661-3; C23 Annex H). |
| Section 5.5 example | `#if ((8 != sizeof(timer_reg_t))` is invalid twice over: `sizeof` cannot appear in a preprocessor conditional, and the parentheses are unbalanced. | Replaced with `static_assert(8 == sizeof(timer_reg_t), ...)`. |
| Section 5.4 example | Includes `<limits.h>` to test `DBL_DIG`. | `DBL_DIG` is defined in `<float.h>`. |
| Rule 3.1.b | Assignment-operator list includes `~=` (not a C operator) and `!=` (a comparison, correctly listed in 3.1.c); omits `<<=` and `>>=`. | List corrected. |
| Footnote 12 | Refers to "the `sizeof` macro." | `sizeof` is an operator. |
| Sections 5.1/5.5 examples | Struct members named `_unused` appear to violate the leading-underscore naming rules. | Legal: those rules reserve such identifiers at file scope; member names occupy member scope. Footnote added. |
| Section 4.2 citation | Footnote links to a 2010 article URL that no longer resolves. | Citation updated to the archived copy. |
