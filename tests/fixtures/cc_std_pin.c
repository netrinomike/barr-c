#include <stdint.h>

int32_t
is_on (int32_t v)
{
    bool flag = (0 < v);
    return flag ? 1 : 0;
}
