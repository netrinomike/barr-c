#include <stdint.h>

int32_t clamp_low(int32_t x)
{
    if(0 > x)
    {
        x = 0;
    }
    return x;
}
