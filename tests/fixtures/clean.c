// The shortlist of longitude words in this file proves the lexical gate
// honors word boundaries and skips leading comment lines.

#include "clean.h"

int32_t g_step_total = 0;

int32_t
clean_step (run_mode_t mode, int32_t shortlist_count)
{
    int32_t result = 0;

    switch (mode)
    {
        case MODE_IDLE:
            result = shortlist_count;
            break;

        case MODE_RUN:
            // Cast is safe: result stays within int32_t range by construction.
            result = (int32_t) (shortlist_count + 1);
            break;

        default:
            result = 0;
            break;
    }

    g_step_total = g_step_total + result;
    return result;
}
