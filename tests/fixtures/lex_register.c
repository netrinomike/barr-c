#include <stdint.h>

int32_t
spin (void)
{
    register int32_t fast_counter = 0;
    fast_counter                  = fast_counter + 1;
    return fast_counter;
}
