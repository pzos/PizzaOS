#define pz_vga_start 0xB8000
#define pz_vga_extent 80 * 25

#define STYLE_WB 0x0F

typedef struct __attribute__((packed)) {
    char character;
    char style;
} vga_char;

volatile vga_char *TEXT_AREA = (vga_char*) pz_vga_start;

void clearwin(){
    vga_char clear_char = {
        .character=' ',
        .style=STYLE_WB
    };

    for(unsigned int i = 0; i < pz_vga_extent; i++){
        TEXT_AREA[i] = clear_char;
    }
}

void putstr(const char *str){
    for(unsigned int i = 0; str[i] != '\0'; i++){
        if (i >= pz_vga_extent)
            break;

        vga_char temp = {
            .character=str[i],
            .style=STYLE_WB
        };

        TEXT_AREA[i] = temp;
    }
}

int pz_SysMain(){
    clearwin();
    const char *welcome_msg = "pzos_kernel: Loaded kernel";
    putstr(welcome_msg);

    return 0;
}