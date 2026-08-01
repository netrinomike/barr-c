#include <stdint.h>

typedef struct
{
    int32_t value;
} widget;

int32_t
widget_value (widget const * p_w)
{
    return p_w->value;
}
