#include "render.h"

#include <pico/stdlib.h>
#include "buffers.h"
#include "colors.h"
#include "vga.h"


static void render_dlores_line(uint line);

static inline uint lores_line_to_mem_offset(uint line) {
    return line * (soft_dlores ? 80 : 40);
}


static void render_lores_line(uint line) {
    // Construct two scanlines for the two different colored cells at the same time
    struct vga_scanline *sl1 = vga_prepare_scanline();
    struct vga_scanline *sl2 = vga_prepare_scanline();
    uint sl_pos = 0;

    const uint8_t *page = soft_page2 ? text_mainmem_page1 : text_mainmem_page2;
    const uint8_t *line_buf = page + lores_line_to_mem_offset(line);

    // Pad 40 pixels on the left to center horizontally
    sl1->data[sl_pos] = (0 | THEN_EXTEND_7) | ((0 | THEN_EXTEND_7) << 16);  // 16 pixels per word
    sl2->data[sl_pos] = (0 | THEN_EXTEND_7) | ((0 | THEN_EXTEND_7) << 16);  // 16 pixels per word
    sl_pos++;
    sl1->data[sl_pos] = (0 | THEN_EXTEND_7) | ((0 | THEN_EXTEND_7) << 16);  // 16 pixels per word
    sl2->data[sl_pos] = (0 | THEN_EXTEND_7) | ((0 | THEN_EXTEND_7) << 16);  // 16 pixels per word
    sl_pos++;
    sl1->data[sl_pos] = (0 | THEN_EXTEND_3) | ((0 | THEN_EXTEND_3) << 16);  // 8 pixels per word
    sl2->data[sl_pos] = (0 | THEN_EXTEND_3) | ((0 | THEN_EXTEND_3) << 16);  // 8 pixels per word
    sl_pos++;


        for(int i = 0; i < 40; i++) {
            uint32_t color1 = ntsc_palette[line_buf[i] & 0xf];
            uint32_t color2 = ntsc_palette[(line_buf[i] >> 4) & 0xf];

            // Each lores pixel is 7 hires pixels, or 14 VGA pixels wide
            sl1->data[sl_pos] = (color1 | THEN_EXTEND_6) | ((color1 | THEN_EXTEND_6) << 16);
            sl2->data[sl_pos] = (color2 | THEN_EXTEND_6) | ((color2 | THEN_EXTEND_6) << 16);
            sl_pos++;
    }

    if(soft_scanline_emulation) {
        // Just insert a blank scanline between each rendered scanline
        sl1->data[sl_pos] = THEN_WAIT_HSYNC;
        sl2->data[sl_pos] = THEN_WAIT_HSYNC;
        sl_pos++;

        sl1->repeat_count = 3;
        sl2->repeat_count = 3;
    } else {
        sl1->repeat_count = 7;
        sl2->repeat_count = 7;
    }

    sl1->length = sl_pos;
    sl2->length = sl_pos;
    vga_submit_scanline(sl1);
    vga_submit_scanline(sl2);
}


static void render_dlores_line(uint line) {
    // Construct two scanlines for the two different colored cells at the same time
    struct vga_scanline *sl1 = vga_prepare_scanline();
    struct vga_scanline *sl2 = vga_prepare_scanline();
    uint sl_pos = 0;

    const uint8_t *page_main = soft_page2 ? text_mainmem_page1 : text_mainmem_page2;
    const uint line_offset = lores_line_to_mem_offset(line);
    const uint8_t *line_main = page_main + line_offset;

    // Pad 40 pixels on the left to center horizontally
    sl1->data[sl_pos] = (0 | THEN_EXTEND_7) | ((0 | THEN_EXTEND_7) << 16);  // 16 pixels per word
    sl2->data[sl_pos] = (0 | THEN_EXTEND_7) | ((0 | THEN_EXTEND_7) << 16);  // 16 pixels per word
    sl_pos++;
    sl1->data[sl_pos] = (0 | THEN_EXTEND_7) | ((0 | THEN_EXTEND_7) << 16);  // 16 pixels per word
    sl2->data[sl_pos] = (0 | THEN_EXTEND_7) | ((0 | THEN_EXTEND_7) << 16);  // 16 pixels per word
    sl_pos++;
    sl1->data[sl_pos] = (0 | THEN_EXTEND_3) | ((0 | THEN_EXTEND_3) << 16);  // 8 pixels per word
    sl2->data[sl_pos] = (0 | THEN_EXTEND_3) | ((0 | THEN_EXTEND_3) << 16);  // 8 pixels per word
    sl_pos++;


        for(int i = 0; i < 80; i+=2) {
            uint32_t color_aux1 = ntsc_palette[line_main[i] & 0xf];
            uint32_t color_aux2 = ntsc_palette[(line_main[i] >> 4) & 0xf];
            uint32_t color_main1 = ntsc_palette[line_main[i+1] & 0xf];
            uint32_t color_main2 = ntsc_palette[(line_main[i+1] >> 4) & 0xf];

            // Each double-lores pixel is 3.5 hires pixels, or 7 VGA pixels wide
            sl1->data[sl_pos] = (color_aux1 | THEN_EXTEND_6) | ((color_main1 | THEN_EXTEND_6) << 16);
            sl2->data[sl_pos] = (color_aux2 | THEN_EXTEND_6) | ((color_main2 | THEN_EXTEND_6) << 16);
            sl_pos++;
        }


    if(soft_scanline_emulation) {
        // Just insert a blank scanline between each rendered scanline
        sl1->data[sl_pos] = THEN_WAIT_HSYNC;
        sl2->data[sl_pos] = THEN_WAIT_HSYNC;
        sl_pos++;

        sl1->repeat_count = 3;
        sl2->repeat_count = 3;
    } else {
        sl1->repeat_count = 7;
        sl2->repeat_count = 7;
    }

    sl1->length = sl_pos;
    sl2->length = sl_pos;
    vga_submit_scanline(sl1);
    vga_submit_scanline(sl2);
}


void render_lores() {
    vga_prepare_frame();
    // Skip 48 lines to center vertically
    vga_skip_lines(48);

    if(soft_dlores) {
        for(uint line = 0; line < 24; line++) {
            render_dlores_line(line);
        }
    } else
    {
        for(uint line = 0; line < 24; line++) {
            render_lores_line(line);
        }
    }
}


void render_mixed_lores() {
    vga_prepare_frame();
    // Skip 48 lines to center vertically
    vga_skip_lines(48);

     if(soft_dlores) {
        for(uint line = 0; line < 20; line++) {
            render_dlores_line(line);
        }
    } else
    {
        for(uint line = 0; line < 20; line++) {
            render_lores_line(line);
        }
    }

    for(uint line = 20; line < 24; line++) {
        render_text_line(line);
    }
}
