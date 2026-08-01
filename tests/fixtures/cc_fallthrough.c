#include <stdint.h>

int32_t
classify (int32_t v)
{
    int32_t r = 0;
    switch (v)
    {
        case 0:
            r = 1;

        case 1:
            r = r + 1;
            break;

        default:
            r = 0;
            break;
    }
    return r;
}
