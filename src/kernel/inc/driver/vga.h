#ifndef __DRIVER_VGA_TEXT
#define __DRIVER_VGA_TEXT

#include <types.h>

#define vga_start 0xB8000
#define vga_extent 80 * 25
#define vga_width 80

#define textColor_black 0
#define textColor_blue 1
#define textColor_green 2
#define textColor_cyan 3
#define textColor_red 4
#define textColor_purple 5
#define textColor_brown 6
#define textColor_grey 7
#define textColor_darkGrey 8
#define textColor_lightBlue 9
#define textColor_lightGreen 10
#define textColor_lightCyan 11
#define textColor_lightRed 12
#define textColor_lightPurple 13
#define textColor_yellow 14
#define textColor_white 15

#define cursor_port_command (u16_t) 0x3D4
#define cursor_port_data (u16_t) 0x3D5

typedef struct  __attribute__((packed)) {
    char character;
    char style;
} vga_char;


u8_t vga_color(const u8_t fg_color, const u8_t bg_color);

void clearwin(const u8_t fg_color, const u8_t bg_color);
void print_char(const char character, const u8_t fg_color, const u8_t bg_color);
void print(const char *string, const u8_t fg_color, const u8_t bg_color);

u16_t get_cursor_pos();
void set_cursor_pos(u8_t x, u8_t y);
void advance_cursor();

void show_cursor();
void hide_cursor();

#endif