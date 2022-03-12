#define VGA_START 0xB8000
#define VGA_EXTENT 80 * 25

#define STYLE_WB 0x0F

typedef struct __attribute__((packed)) {
    char character;
    char style;
} vga_char;

volatile vga_char *TEXT_AREA = (vga_char*) VGA_START;

void clearwin(){
    vga_char clear_char = {
        .character=' ',
        .style=STYLE_WB
    };

    for(unsigned int i = 0; i < VGA_EXTENT; i++){
        TEXT_AREA[i] = clear_char;
    }
}

void putstr(const char *str){
    for(unsigned int i = 0; str[i] != '\0'; i++){
        if (i >= VGA_EXTENT)
            break;

        vga_char temp = {
            .character=str[i],
            .style=STYLE_WB
        };

        TEXT_AREA[i] = temp;
    }
}

void main(){
    clearwin();
    const char *welcome_msg = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Pretium nibh ipsum consequat nisl vel pretium lectus quam. Ullamcorper dignissim cras tincidunt lobortis feugiat vivamus at augue eget. Scelerisque fermentum dui faucibus in ornare quam. Tempus egestas sed sed risus. Aenean vel elit scelerisque mauris. At auctor urna nunc id cursus metus aliquam. Enim sed faucibus turpis in eu mi bibendum neque egestas. Suspendisse in est ante in nibh mauris. Morbi tincidunt ornare massa eget egestas purus viverra accumsan. Sodales neque sodales ut etiam sit. Nisl rhoncus mattis rhoncus urna neque. Cursus eget nunc scelerisque viverra mauris in aliquam sem. Nunc aliquet bibendum enim facilisis gravida neque convallis a. Elementum nisi quis eleifend quam adipiscing vitae proin.";
    putstr(welcome_msg);
	for(;;);
    //return 0;
}