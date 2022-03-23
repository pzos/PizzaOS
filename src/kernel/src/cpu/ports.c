#include <cpu/ports.h>

u8_t byte_in(u16_t port) {
    u8_t result;
    __asm__ volatile ("in %%dx, %%al" : "=a" (result) : "d" (port));
    return result;
}

void byte_out(u16_t port, u8_t data) {
    __asm__ volatile ("out %%al, %%dx" : : "a" (data), "d" (port));
}