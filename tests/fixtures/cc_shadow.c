#include <stdint.h>

int32_t
nest (int32_t depth)
{
    int32_t level = depth;
    if (0 < level)
    {
        int32_t inner_level = 0;
        int32_t level       = inner_level;
        depth               = level;
    }
    return depth + level;
}
