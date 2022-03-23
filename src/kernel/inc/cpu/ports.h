#ifndef __CPU_PORTS
#define __CPU_PORTS

#include <types.h>

u8_t byte_in(u16_t port);
void byte_out(u16_t port, u8_t data);

#endif