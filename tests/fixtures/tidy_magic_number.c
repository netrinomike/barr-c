#include <stdint.h>

int32_t
total_up (void)
{
    int32_t t = 0;
    for (int32_t i = 0; i < 37; i++)
    {
        t = t + 1;
    }
    return t;
}
