#include <stdint.h>

#define TWICE(x) (x + x)

int32_t
doubled (int32_t v)
{
    return TWICE(v);
}
