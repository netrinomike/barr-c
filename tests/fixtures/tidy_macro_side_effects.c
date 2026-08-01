#include <stdint.h>

#define MAX2(a, b) (((a) > (b)) ? (a) : (b))

int32_t
drain (int32_t i)
{
    int32_t m = MAX2(i++, 0);
    return m + i;
}
