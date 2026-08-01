#include <stdint.h>

int32_t counter_total = 0;

int32_t
tick (void)
{
    counter_total = counter_total + 1;
    return counter_total;
}
