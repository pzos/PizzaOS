#ifndef __VGA
#define __VGA

#define vga_start 0xB8000
#define vga_width 80
#define vga_extent 80 * 25

#define color_black 0
#define color_blue 1
#define color_green 2
#define color_cyan 3
#define color_red 4o
#define color_purple 5
#define color_brown 6
#define color_gray 7
#define color_darkGray 8
#define color_lightBlue 9
#define color_lightGreen 10
#define color_lightCyan 11
#define color_lightRed 12
#define color_lightPurple 13
#define color_yellow 14
#define color_white 15

#define cursor_port_command (unsigned short) 0x3D4
#define cursor_port_data (unsigned short) 0x3D5

typedef struct __attribute__((packed)) {
    char character;
    char style;
} vga_char;

unsigned char vga_color(const unsigned char color_fg, const unsigned char color_bg);

void clear_console(unsigned char color_fg, unsigned char color_bg);
void print_str(const char *str, unsigned char color_fg, unsigned char color_bg);
void print_char(const char character, const unsigned char color_fg, const unsigned char color_bg);

void show_cursor();
void hide_cursor();

void advance_cursor();
void set_cursor_pos(unsigned char x, unsigned char y);
unsigned short get_cursor_pos();

#endif