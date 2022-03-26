#include <cpu/ports.h>
#include <driver/vga.h>

int main() {
    clear_console(color_white, color_black);
    const char *msg_loadedKernel = "krnl: Loaded kernel.";
    print_str(msg_loadedKernel, color_white, color_black);
    const char *msg_testColors_black_white = "krnl: Testing black-on-white text";
    print_str(msg_testColors_black_white, color_white, color_black);

    return 0;
}