#include <string.h>
#include <hardware/pio.h>
#include "abus.h"
#include "abus.pio.h"
#include "board_config.h"
#include "buffers.h"
#include "colors.h"
#include "device_regs.h"


#if CONFIG_PIN_APPLEBUS_PHI0 != PHI0_GPIO
#error CONFIG_PIN_APPLEBUS_PHI0 and PHI0_GPIO must be set to the same pin
#endif


enum {
    ABUS_MAIN_SM = 0,
};



static void abus_main_setup(PIO pio, uint sm) {
    uint program_offset = pio_add_program(pio, &abus_program);
    pio_sm_claim(pio, sm);

    pio_sm_config c = abus_program_get_default_config(program_offset);

    // set the bus R/W pin as the jump pin
    sm_config_set_jmp_pin(&c, CONFIG_PIN_APPLEBUS_RW);

    // map the IN pin group to the data signals
    sm_config_set_in_pins(&c, CONFIG_PIN_APPLEBUS_DATA_BASE);

    // map the SET pin group to the bus transceiver enable signals
    sm_config_set_set_pins(&c, CONFIG_PIN_APPLEBUS_CONTROL_BASE, 3);

    // configure left shift into ISR & autopush every 26 bits
    sm_config_set_in_shift(&c, false, true, 26);

    pio_sm_init(pio, sm, program_offset, &c);

    // configure the GPIOs
    // Ensure all transceivers will start disabled
    pio_sm_set_pins_with_mask(
        pio, sm, (uint32_t)0x7 << CONFIG_PIN_APPLEBUS_CONTROL_BASE, (uint32_t)0x7 << CONFIG_PIN_APPLEBUS_CONTROL_BASE);
    pio_sm_set_pindirs_with_mask(pio, sm, (0x7 << CONFIG_PIN_APPLEBUS_CONTROL_BASE),
        (1 << CONFIG_PIN_APPLEBUS_PHI0) | (0x7 << CONFIG_PIN_APPLEBUS_CONTROL_BASE) | (0x3ff << CONFIG_PIN_APPLEBUS_DATA_BASE));

    // In the rev A schematic this pin was originally used to control the data bus pins transceiver direction
    // so that bus reads could be responded to with data. This code has since been removed so the GPIO could be
    // repurposed.
    //
    // A pull-down is set on this pin to remain compatible with these rev A based designs. This will ensure that
    // by default the data transceiver direction in "inward".
    gpio_set_pulls(CONFIG_PIN_APPLEBUS_SYNC, false, true);

    // Disable input synchronization on input pins that are sampled at known stable times
    // to shave off two clock cycles of input latency
    pio->input_sync_bypass |= (0x3ff << CONFIG_PIN_APPLEBUS_DATA_BASE);

    pio_gpio_init(pio, CONFIG_PIN_APPLEBUS_PHI0);
    gpio_set_pulls(CONFIG_PIN_APPLEBUS_PHI0, false, false);

    for(int pin = CONFIG_PIN_APPLEBUS_CONTROL_BASE; pin < CONFIG_PIN_APPLEBUS_CONTROL_BASE + 3; pin++) {
        pio_gpio_init(pio, pin);
    }

    for(int pin = CONFIG_PIN_APPLEBUS_DATA_BASE; pin < CONFIG_PIN_APPLEBUS_DATA_BASE + 10; pin++) {
        pio_gpio_init(pio, pin);
        gpio_set_pulls(pin, false, false);
    }
}


void abus_init() {

    abus_main_setup(CONFIG_ABUS_PIO, ABUS_MAIN_SM);

    pio_enable_sm_mask_in_sync(CONFIG_ABUS_PIO, (1 << ABUS_MAIN_SM));
}


// Shadow parts of the Apple's memory by observing the bus write cycles
static void shadow_memory(bool is_write, uint_fast16_t address, uint32_t value) {

    if((address>=0x1000) && (address<0xA000))
    {
        if(is_write)
            main_memory[address] = value & 0xff;
    }

}


void abus_loop() {
    while(1) {
        uint32_t value = pio_sm_get_blocking(CONFIG_ABUS_PIO, ABUS_MAIN_SM);

        const bool is_devsel = ((value & (1u << (CONFIG_PIN_APPLEBUS_DEVSEL - CONFIG_PIN_APPLEBUS_DATA_BASE))) == 0);
        const bool is_write = ((value & (1u << (CONFIG_PIN_APPLEBUS_RW - CONFIG_PIN_APPLEBUS_DATA_BASE))) == 0);
        if(is_devsel) {
            // device slot access
            if(is_write) {
                uint_fast8_t device_reg = (value >> 10) & 0xf;
                device_write(device_reg, value & 0xff);
            }
            gpio_xor_mask(1u << PICO_DEFAULT_LED_PIN);
        } else {
            // some other bus cycle - handle memory & soft-switch shadowing
            uint_fast16_t address = (value >> 10) & 0xffff;
            shadow_memory(is_write, address, value);
        }
    }
}
