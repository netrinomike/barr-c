#include <stdint.h>

#if MISSING_FEATURE_FLAG
int32_t g_enabled = 1;
#else
int32_t g_enabled = 0;
#endif
