#include <cpu/ports.h>
#include <driver/vga.h>

void clear_console() {
    vga_char clear_char = {
        .character=' ',
        .style=color_white
    };

    for(unsigned int i = 0; i < vga_extent; i++) {
        textArea[i] = clear_char;
    }
}

void print_str(const char *str) {
    for(unsigned int i = 0; str[i] != '\0'; i++) {
        if (i >= vga_extent)
            break;

        vga_char temp = {
            .character=str[i],
            .style=color_white
        };

        textArea[i] = temp;
    }
}

int main() {
    clear_console();
    const char *msg_loadedKernel = "krnl: Loaded kernel. with 858";
    print_str(msg_loadedKernel);

    return 0;
}