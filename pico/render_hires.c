#include "render.h"

#include <pico/stdlib.h>
#include "buffers.h"
#include "colors.h"
#include "vga.h"


static void render_hires_line(uint line);
static void render_dhires_line(uint line);
static void render_qhires_line(uint line);
static void render_mhires_line(uint line);

static inline uint hires_line_to_mem_offset(uint line) {
    return line * 70;
}
static inline uint qhires_line_to_mem_offset(uint line) {
    return line * 35;
}
static inline uint dhires_line_to_mem_offset(uint line) {
    return line * 140;
}
static inline  uint32_t getBits(uint8_t bits,uint8_t mask) {
  if((bits & mask)==0)   return (uint32_t)(ntsc_palette[0]<<16 | ntsc_palette[0]);
  return (uint32_t)(ntsc_palette[15]<<16 | ntsc_palette[15]);
}

static inline  uint32_t getQuadBits(uint8_t bits,uint8_t mask,uint8_t mask2) {
  if(((bits & mask2)==0) && ((bits & mask)==0))  return (uint32_t)(ntsc_palette[0]<<16 | ntsc_palette[0]);
  if(((bits & mask2)==0) && ((bits & mask)!=0)) return (uint32_t)(ntsc_palette[0]<<16 | ntsc_palette[15]);
  if(((bits & mask2)!=0) && ((bits & mask)==0))  return (uint32_t)(ntsc_palette[15]<<16 | ntsc_palette[0]);
  return (uint32_t)(ntsc_palette[15]<<16 | ntsc_palette[15]);
}

void render_hires(bool mixed) {
    vga_prepare_frame();
    // Skip 48 lines to center vertically
    vga_skip_lines(48);

    void (*render_hgr_line)(uint) = render_hires_line;

    if(soft_dhires) {
        render_hgr_line = render_dhires_line;
    }

    if(soft_qhires) {
        render_hgr_line = render_qhires_line;
    }

    if(soft_mhires) {
        render_hgr_line = render_mhires_line;
    }

    for(uint line = 0; line < 160; line++) {
        render_hgr_line(line);
    }

    if(mixed) {
        for(uint line = 20; line < 24; line++) {
            render_text_line(line);
        }
    } else {
        for(uint line = 160; line < 192; line++) {
            render_hgr_line(line);
        }
    }
}


static void render_hires_line(uint line) {
    uint sl_pos = 0;


    const uint8_t *page = soft_page2 ? hires_mainmem_page2 : hires_mainmem_page1;
    const uint8_t *line_main = page + hires_line_to_mem_offset(line);
    struct vga_scanline *sl = vga_prepare_scanline();

    // Pad 40 pixels on the left to center horizontally
    sl->data[sl_pos++] = (0 | THEN_EXTEND_7) | ((0 | THEN_EXTEND_7) << 16);  // 16 pixels
    sl->data[sl_pos++] = (0 | THEN_EXTEND_7) | ((0 | THEN_EXTEND_7) << 16);  // 16 pixels
    sl->data[sl_pos++] = (0 | THEN_EXTEND_3) | ((0 | THEN_EXTEND_3) << 16);  // 8 pixels

    // Standard 140x192 16-color hires mode
    uint_fast8_t dot1 = 0;

    for(uint i = 0; i < 70; i++) {
        dot1 = line_main[i];

        // Convert each 4-bit sequence into the hires colored pixel
        uint32_t pixeldata = ntsc_palette[dot1 & 0xf];
        pixeldata |= ntsc_palette[dot1 & 0xf] << 16;
        sl->data[sl_pos++] = pixeldata;
        sl->data[sl_pos++] = pixeldata;
        dot1 = dot1 >> 4;
        pixeldata = ntsc_palette[dot1 & 0xf];
        pixeldata |= ntsc_palette[dot1 & 0xf] << 16;
        sl->data[sl_pos++] = pixeldata;
        sl->data[sl_pos++] = pixeldata;
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

static void render_qhires_line(uint line) {
    uint sl_pos = 0;

    const uint8_t *page = soft_page2 ? hires_mainmem_page2 : hires_mainmem_page1;
    const uint8_t *line_main = page + hires_line_to_mem_offset(line);
    struct vga_scanline *sl = vga_prepare_scanline();

    // Pad 40 pixels on the left to center horizontally
    sl->data[sl_pos++] = (0 | THEN_EXTEND_7) | ((0 | THEN_EXTEND_7) << 16);  // 16 pixels
    sl->data[sl_pos++] = (0 | THEN_EXTEND_7) | ((0 | THEN_EXTEND_7) << 16);  // 16 pixels
    sl->data[sl_pos++] = (0 | THEN_EXTEND_3) | ((0 | THEN_EXTEND_3) << 16);  // 8 pixels


    // Standard 560x192 2-color hires mode
    for(uint i = 0; i < 70;) {
        uint8_t bits=line_main[i++];
        sl->data[sl_pos++] =getQuadBits(bits,0x80,0x40);
        sl->data[sl_pos++] =getQuadBits(bits,0x20,0x10);
        sl->data[sl_pos++] =getQuadBits(bits,0x08,0x04);
        sl->data[sl_pos++] =getQuadBits(bits,0x02,0x01);
        bits=line_main[i++];
        sl->data[sl_pos++] =getQuadBits(bits,0x80,0x40);
        sl->data[sl_pos++] =getQuadBits(bits,0x20,0x10);
        sl->data[sl_pos++] =getQuadBits(bits,0x08,0x04);
        sl->data[sl_pos++] =getQuadBits(bits,0x02,0x01);
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

static void render_mhires_line(uint line) {
    uint sl_pos = 0;

    const uint8_t *page = soft_page2 ? hires_mainmem_page2 : hires_mainmem_page1;
    const uint8_t *line_main = page + qhires_line_to_mem_offset(line);
    struct vga_scanline *sl = vga_prepare_scanline();

    // Pad 40 pixels on the left to center horizontally
    sl->data[sl_pos++] = (0 | THEN_EXTEND_7) | ((0 | THEN_EXTEND_7) << 16);  // 16 pixels
    sl->data[sl_pos++] = (0 | THEN_EXTEND_7) | ((0 | THEN_EXTEND_7) << 16);  // 16 pixels
    sl->data[sl_pos++] = (0 | THEN_EXTEND_3) | ((0 | THEN_EXTEND_3) << 16);  // 8 pixels


    // Standard 280x192 2-color hires mode
    for(uint i = 0; i < 35;) {
        uint8_t bits=line_main[i++];
        sl->data[sl_pos++] =getBits(bits,0x80);
        sl->data[sl_pos++] =getBits(bits,0x40);
        sl->data[sl_pos++] =getBits(bits,0x20);
        sl->data[sl_pos++] =getBits(bits,0x10);
        sl->data[sl_pos++] =getBits(bits,0x08);
        sl->data[sl_pos++] =getBits(bits,0x04);
        sl->data[sl_pos++] =getBits(bits,0x02);
        sl->data[sl_pos++] =getBits(bits,0x01);
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

static void render_dhires_line(uint line) {
    uint sl_pos = 0;


    const uint8_t *page = hires_mainmem_page1;
    const uint8_t *line_main = page + dhires_line_to_mem_offset(line);
    struct vga_scanline *sl = vga_prepare_scanline();

    // Pad 40 pixels on the left to center horizontally
    sl->data[sl_pos++] = (0 | THEN_EXTEND_7) | ((0 | THEN_EXTEND_7) << 16);  // 16 pixels
    sl->data[sl_pos++] = (0 | THEN_EXTEND_7) | ((0 | THEN_EXTEND_7) << 16);  // 16 pixels
    sl->data[sl_pos++] = (0 | THEN_EXTEND_3) | ((0 | THEN_EXTEND_3) << 16);  // 8 pixels

    // Standard 280x192 16-color hires mode
    uint_fast8_t dot1 = 0;

    for(uint i = 0; i < 140;) {
        dot1 = line_main[i++];
        // Convert each 4-bit sequence into the hires colored pixel
        uint32_t pixeldata = ntsc_palette[dot1 & 0xf];
        pixeldata |= ntsc_palette[dot1 & 0xf] << 16;
        sl->data[sl_pos++] = pixeldata;
        dot1 = dot1 >> 4;
        pixeldata = ntsc_palette[dot1 & 0xf];
        pixeldata |= ntsc_palette[dot1 & 0xf] << 16;
        sl->data[sl_pos++] = pixeldata;
        dot1 = line_main[i++];
        // Convert each 4-bit sequence into the hires colored pixel
        pixeldata = ntsc_palette[dot1 & 0xf];
        pixeldata |= ntsc_palette[dot1 & 0xf] << 16;
        sl->data[sl_pos++] = pixeldata;
        dot1 = dot1 >> 4;
        pixeldata = ntsc_palette[dot1 & 0xf];
        pixeldata |= ntsc_palette[dot1 & 0xf] << 16;
        sl->data[sl_pos++] = pixeldata;

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
