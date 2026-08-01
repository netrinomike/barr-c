#include <stdint.h>

int32_t
drain_queue (int32_t n)
{
    int32_t count = 0;

retry:
    if (count < n)
    {
        count = count + 1;
        goto retry;
    }
    return count;
}
