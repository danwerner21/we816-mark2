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
    case 0x00:
        if(data & 0x01)
            soft_scanline_emulation = true;
        if(data & 0x02)
            soft_scanline_emulation = false;
#ifdef APPLE_MODEL_IIPLUS
        if(data & 0x04)
            videx_vterm_enable();
        if(data & 0x08)
            videx_vterm_disable();
#endif
        break;

    // soft-monochrome color setting
    case 0x01:
        if(data & 0x03)
            mono_fg_color = mono_fg_colors[data & 0x3];
        if(data & 0x30)
            mono_bg_color = mono_bg_colors[(data >> 4) & 0x3];
        if(data & 0x40)
            soft_force_alt_textcolor = true;
        if(data & 0x80)
            soft_force_alt_textcolor = false;
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
    case 0x10 ... 0x1f:
        // This is now open for use
        break;
    default:;
    }
}
