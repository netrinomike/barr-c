#include <stdint.h>

uint8_t
last_of (int32_t n)
{
    uint8_t buf[n];
    buf[0] = 1u;
    return buf[0];
}
