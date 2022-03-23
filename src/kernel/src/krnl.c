#include <driver/vga.h>

int main() {
    set_cursor_pos(0, 0);
    show_cursor();
    clearwin(textColor_black, textColor_white);

    const char *first = "Now we have a more advanced vga driver that does what we want! ";

    print(first, textColor_black, textColor_white);

    const char *second = "It even wraps the text around the screen and moves the cursor correctly. ";

    print(second, textColor_black, textColor_white);

    const char *third = "But if we reach the end of the screen it still doesn't quite scroll properly...";

    print(third, textColor_black, textColor_white);
    
    return 0;
}