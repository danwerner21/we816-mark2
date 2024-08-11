#include "render.h"

#include <pico/stdlib.h>
#include "buffers.h"
#include "colors.h"
#include "textfont/textfont.h"
#include "vga.h"


static inline uint text_line_to_mem_offset(uint line) {
    return line * (soft_80col ? 80 : 40);
}

static inline uint_fast8_t char_text_bits(uint_fast8_t ch, uint_fast8_t glyph_line) {

    uint_fast8_t bits = character_rom[((uint_fast16_t)ch << 3) + glyph_line];
    return bits  & 0x7f;
}

void render_text() {
    vga_prepare_frame();
    // Skip 48 lines to center vertically
    vga_skip_lines(48);

    for(int line = 0; line < 24; line++) {
        render_text_line(line);
    }
}


void render_text_line(unsigned int line) {
    const uint line_offset = text_line_to_mem_offset(line);

    const uint8_t *page_main = soft_page2 ? text_mainmem_page2 : text_mainmem_page1;
    const uint8_t *line_main = page_main + line_offset;
    const uint8_t *line_mainc = page_main + line_offset + 0x800;
    const uint8_t *line_maini = page_main + line_offset + 1;
    const uint8_t *line_mainci = page_main + line_offset + 0x801;

    uint8_t fg = 0;
    uint8_t bg = 0;
    uint8_t fg1 = 0;
    uint8_t bg1 = 0;

    for(uint glyph_line = 0; glyph_line < 8; glyph_line++) {
        struct vga_scanline *sl = vga_prepare_scanline();
        uint sl_pos = 0;
        uint_fast8_t char_a, char_b;
        register uint_fast8_t color_a, color_b;
        uint_fast16_t bits;

        // Pad 40 pixels on the left to center horizontally
        sl->data[sl_pos++] = (0 | THEN_EXTEND_7) | ((0 | THEN_EXTEND_7) << 16);  // 16 pixels
        sl->data[sl_pos++] = (0 | THEN_EXTEND_7) | ((0 | THEN_EXTEND_7) << 16);  // 16 pixels
        sl->data[sl_pos++] = (0 | THEN_EXTEND_3) | ((0 | THEN_EXTEND_3) << 16);  // 8 pixels
        uint col = 0;
        for(int i = 0; i < 40; i++) {
            // Grab 14 pixels from the next two characters. If an aux memory bank was provided (80 column mode is on)
            // then the first character comes from that, otherwise both characters just come from main memory.
            if(soft_80col) {
                char_a = line_main[col];
                color_a = line_mainc[col];
                char_b = line_maini[col];
                color_b = line_mainci[col];
                bits = ((uint_fast16_t)char_text_bits(char_b, glyph_line) << 7) | (uint_fast16_t)char_text_bits(char_a, glyph_line);
                fg = ntsc_palette[color_a & 0x0f];
                bg = ntsc_palette[(color_a & 0xf0)>>4];
                fg1 = ntsc_palette[color_b & 0x0f];
                bg1 = ntsc_palette[(color_b & 0xf0)>>4];
                // Render each pair of bits into a pair of pixels, least significant bit first
                 // unroll for speed
                //0
                sl->data[sl_pos] = (((bits & 0x02) ? fg : bg) << 16) |
                                       ((bits & 0x01) ? fg : bg);
                sl_pos++;
                bits >>= 2;
                //1
                sl->data[sl_pos] = (((bits & 0x02) ? fg : bg) << 16) |
                                       ((bits & 0x01) ? fg : bg);
                sl_pos++;
                bits >>= 2;
                // 2
                sl->data[sl_pos] = (((bits & 0x02) ? fg : bg) << 16) |
                                       ((bits & 0x01) ? fg : bg);
                sl_pos++;
                bits >>= 2;
                // 3
                sl->data[sl_pos] = (((bits & 0x02) ? fg : bg) << 16) |
                                       ((bits & 0x01) ? fg1 : bg1);
                sl_pos++;
                bits >>= 2;
                // 4
                sl->data[sl_pos] = (((bits & 0x02) ? fg1 : bg1) << 16) |
                                       ((bits & 0x01) ? fg1 : bg1);
                sl_pos++;
                bits >>= 2;
                // 5
                sl->data[sl_pos] = (((bits & 0x02) ? fg1 : bg1) << 16) |
                                       ((bits & 0x01) ? fg1 : bg1);
                sl_pos++;
                bits >>= 2;
                // 6
                sl->data[sl_pos] = (((bits & 0x02) ? fg1 : bg1) << 16) |
                                       ((bits & 0x01) ? fg1 : bg1);
                sl_pos++;
                col+=2;
            } else {
                char_a = line_main[col];
                color_a = line_mainc[col++];
                bits = (uint_fast16_t)char_text_bits(char_a, glyph_line);
                // Render each pair of bits into a pair of pixels, least significant bit first
                fg =   ntsc_palette[color_a & 0x0f];
                bg =   ntsc_palette[(color_a & 0xf0)>>4];
                for(int i = 0; i < 7; i++) {
                    sl->data[sl_pos] = (((bits & 0x01) ? fg : bg) << 16) |
                                       ((bits & 0x01) ? fg : bg);
                    sl_pos++;
                    bits >>= 1;
                }
            }
        }

        if(soft_scanline_emulation) {
            // Just insert a blank scanline between each rendered scanline
            sl->data[sl_pos++] = THEN_WAIT_HSYNC;
        } else {
            sl->repeat_count = 1;
        }
        sl->length = sl_pos;
        vga_submit_scanline(sl);
    }
}