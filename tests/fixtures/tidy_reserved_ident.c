#include <stdint.h>

int32_t _hidden_total = 0;

int32_t
bump (void)
{
    _hidden_total = _hidden_total + 1;
    return _hidden_total;
}
