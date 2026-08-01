#include <stdint.h>

int32_t seed_scale(int32_t raw){
    int32_t scaled=raw;
    if(0<raw){
        scaled=raw+1;
    }
    return scaled;
}
