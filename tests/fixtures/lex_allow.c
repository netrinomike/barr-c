#include <stdint.h>

short legacy_reg = 0; // vendor API requires this width; barr-c:allow

int32_t
read_legacy (void)
{
    return legacy_reg; // barr-c:allow
}
