#ifndef __VGA
#define __VGA

#define vga_start 0xB8000
#define vga_width 80
#define vga_extent 80 * 25

#define COLOR_BLK 0     // Black
#define COLOR_BLU 1     // Blue
#define COLOR_GRN 2     // Green
#define COLOR_CYN 3     // Cyan
#define COLOR_RED 4     // Red
#define COLOR_PRP 5     // Purple
#define COLOR_BRN 6     // Brown
#define COLOR_GRY 7     // Gray
#define COLOR_DGY 8     // Dark Gray
#define COLOR_LBU 9     // Light Blue
#define COLOR_LGR 10    // Light Green
#define COLOR_LCY 11    // Light Cyan
#define COLOR_LRD 12    // Light Red
#define COLOR_LPP 13    // Light Purple
#define COLOR_YEL 14    // Yellow
#define textColor_white 15

#define cursor_port_command (unsigned short) 0x3D4
#define cursor_port_data (unsigned short) 0x3D5

typedef struct __attribute__((packed)) {
    char character;
    char style;
} vga_char;

unsigned char vga_color(const unsigned char fg_color, const unsigned char bg_color);

//void clear_console(const unsigned char fg_color, const unsigned char bg_color);
//void putchar(const char character, const unsigned char fg_color, const unsigned char bg_color);
//void print_str(const char *string, const unsigned char fg_color, const unsigned char bg_color);

unsigned short get_cursor_pos();

void show_cursor();
void hide_cursor();

void advance_cursor();
void set_cursor_pos(unsigned char x, unsigned char y);

#endif