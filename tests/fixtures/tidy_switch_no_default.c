#include <stdint.h>

int32_t
map_value (int32_t v)
{
    int32_t r = 0;
    switch (v)
    {
        case 0:
            r = 1;
            break;

        case 1:
            r = 0;
            break;
    }
    return r;
}
