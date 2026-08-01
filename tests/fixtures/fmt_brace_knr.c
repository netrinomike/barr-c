#include <stdint.h>

int32_t poll_twice(int32_t x)
{
    if (0 == x) {
        x = 1;
    }
    return x;
}
