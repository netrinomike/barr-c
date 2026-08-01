#ifndef CLEAN_H
#define CLEAN_H

#include <stdint.h>

typedef enum
{
    MODE_IDLE = 0,
    MODE_RUN  = 1
} run_mode_t;

int32_t clean_step (run_mode_t mode, int32_t shortlist_count);

#endif /* CLEAN_H */
