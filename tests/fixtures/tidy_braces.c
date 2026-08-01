#include <stdint.h>

int32_t
poll_once (int32_t x)
{
    if (0 == x)
        x = 1;
    return x;
}
