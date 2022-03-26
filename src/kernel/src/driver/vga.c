#include <cpu/ports.h>
#include <driver/vga.h>

volatile vga_char *textArea = (vga_char*) vga_start;

unsigned char vga_color(const unsigned char color_fg, const unsigned char color_bg) {
    return (color_bg << 4) | (color_fg & 0x0F);
}

void clear_console(unsigned char color_fg, unsigned char color_bg) {
    unsigned char clear_color = vga_color(color_fg, color_bg);
    const char char_space = ' ';
    
    vga_char clear_char = {
        .character=char_space,
        .style=clear_color
    };

    for(unsigned int i = 0; i < vga_extent; i++) {
        textArea[i] = clear_char;
    }
}

void print_str(const char *str, unsigned char color_fg, unsigned char color_bg) {
    for(unsigned int i = 0; str[i] != '\0'; i++){
        unsigned char text_color = vga_color(color_fg, color_bg);
        
        if (i >= vga_extent) {
            break;
        }

        vga_char temp = {
            .character=str[i],
            .style=text_color
        };

        textArea[i] = temp;
    }
}

/*void print_char(const char character, const unsigned char color_fg, const unsigned char color_bg) {
    unsigned char style = vga_color(color_fg, color_bg);
    vga_char printed = {
        .character = character,
        .style = style
    };

    unsigned short cursor_position = get_cursor_pos();
    textArea[cursor_position] = printed;
}

unsigned short get_cursor_pos() {
    unsigned short position = 0;

    byte_out(cursor_port_command, 0x0F);
    position |= byte_in(cursor_port_data);

    byte_out(cursor_port_command, 0x0E);
    position |= byte_in(cursor_port_data) << 8;

    return position;
}


void show_cursor() {
    unsigned char current;

    byte_out(cursor_port_command, 0x0A);
    current = byte_in(cursor_port_data);
    byte_out(cursor_port_data, current & 0xC0);

    byte_out(cursor_port_command, 0x0B);
    current = byte_in(cursor_port_data);
    byte_out(cursor_port_data, current & 0xE0);
}


void hide_cursor() {
    byte_out(cursor_port_command, 0x0A);
    byte_out(cursor_port_data, 0x20);
}


void advance_cursor() {
    unsigned short pos = get_cursor_pos();
    pos++;

    if (pos >= vga_extent) {
        pos = vga_extent - 1;
    }

    byte_out(cursor_port_command, 0x0F);
    byte_out(cursor_port_data, (unsigned char) (pos & 0xFF));

    byte_out(cursor_port_command, 0x0E);
    byte_out(cursor_port_data, (unsigned char) ((pos >> 8) & 0xFF));
}


void set_cursor_pos(unsigned char x, unsigned char y) {
    unsigned short pos = x + ((unsigned short) vga_width * y);

    if (pos >= vga_extent) {
        pos = vga_extent - 1;
    }

    byte_out(cursor_port_command, 0x0F);
    byte_out(cursor_port_data, (unsigned char) (pos & 0xFF));

    byte_out(cursor_port_command, 0x0E);
    byte_out(cursor_port_data, (unsigned char) ((pos >> 8) & 0xFF));
}
*/