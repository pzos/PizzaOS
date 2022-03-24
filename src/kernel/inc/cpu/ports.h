#ifndef __CPU_PORTS
#define __CPU_PORTS

unsigned char byte_in(unsigned short port);
void byte_out(unsigned short port, unsigned char data);

#endif