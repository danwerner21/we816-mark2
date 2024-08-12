#include "device_regs.h"

#include <string.h>
#include "buffers.h"
#include "colors.h"
#include "config.h"
#include "textfont/textfont.h"



static unsigned int char_write_offset;


// Handle a write to one of the registers on this device's slot
void device_write(uint_fast8_t reg, uint_fast8_t data) {
    switch(reg) {
    // Scan Line Emulation
    case 0x00:
        if(data & 0x01)
            soft_scanline_emulation = true;
        if(data & 0x02)
            soft_scanline_emulation = false;
        break;

    // Select Page 2
    case 0x01:
        if(data & 0x01)
            soft_page2 = false;
        if(data & 0x02)
            soft_page2 = true;
        break;

    // character generator write offset
    case 0x02:
        char_write_offset = data << 3;
        break;

    // character generator write
    case 0x03:
        character_rom[char_write_offset] = data;
        char_write_offset = (char_write_offset + 1) % sizeof(character_rom);
        break;

    // device command
    case 0x04:
        execute_device_command(data);
        break;

    // Text Mode
    case 0x05:
        if(data & 0x01)
            soft_text = true;
        if(data & 0x02)
            soft_text = false;
        break;

    // Lores Mode
    case 0x06:
        if(data & 0x01)
            soft_lores = true;
        if(data & 0x02)
            soft_lores = false;
        break;

    // Double Lores Mode
    case 0x07:
        if(data & 0x01)
            soft_dlores = true;
        if(data & 0x02)
            soft_dlores = false;
        break;

    // Hires Mode
    case 0x08:
        if(data & 0x01)
           soft_hires = true;
        if(data & 0x02)
            soft_hires = false;
        break;

    // Double Hires Mode
    case 0x09:
        if(data & 0x01)
            soft_dhires = true;
        if(data & 0x02)
            soft_dhires = false;
        break;

    // 80 Col Mode
    case 0x0A:
        if(data & 0x01)
            soft_80col = true;
        if(data & 0x02)
            soft_80col = false;
        break;

    // Mixed Mode
    case 0x0B:
        if(data & 0x01)
            soft_mixed = true;
        if(data & 0x02)
            soft_mixed = false;
        break;

    // Quad Hires
    case 0x0C:
        if(data & 0x01)
            soft_qhires = true;
        if(data & 0x02)
            soft_qhires = false;
        break;

    // Mono Hires
    case 0x0D:
        if(data & 0x01)
            soft_mhires = true;
        if(data & 0x02)
            soft_mhires = false;
        break;

    default:;
    }
}


// Handle a write to the "command" register to perform some one-shot action based on the
// command value.
//
// Note: some of these commands could take a long time (relative to 6502 bus cycles) so
// some bus activity may be missed. Other projects like the V2-Analog delegate this execution
// to the other (VGA) core to avoid this. Maybe do this if the missed bus cycles become a noticable
// issue; I only expect it would happen when some config is being saved, which is not done often.
void execute_device_command(uint_fast8_t cmd) {
    switch(cmd) {
    case 0x00:
        // reset to the default configuration
        config_load_defaults();
        break;
    case 0x01:
        // reset to the saved configuration
        config_load();
        break;
    case 0x02:
        // save the current configuration
        config_save();
        break;
    default:;
    }
}
