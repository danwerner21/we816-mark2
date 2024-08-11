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

typedef void (*shadow_handler)(bool is_write, uint_fast16_t address, uint_fast8_t data);

static shadow_handler softsw_handlers[256];


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


static void shadow_softsw_00(bool is_write, uint_fast16_t address, uint_fast8_t data) {
    if(is_write)
        soft_page2 = false;
}

static void shadow_softsw_01(bool is_write, uint_fast16_t address, uint_fast8_t data) {
    if(is_write)
        soft_page2 = true;
}

static void shadow_softsw_04(bool is_write, uint_fast16_t address, uint_fast8_t data) {
    if(is_write)
        soft_ramwrt = false;
}

static void shadow_softsw_05(bool is_write, uint_fast16_t address, uint_fast8_t data) {
    if(is_write)
        soft_ramwrt = true;
}

static void shadow_softsw_0c(bool is_write, uint_fast16_t address, uint_fast8_t data) {
    if(is_write)
        soft_80col = false;
}

static void shadow_softsw_0d(bool is_write, uint_fast16_t address, uint_fast8_t data) {
    if(is_write)
        soft_80col = true;
}

static void shadow_softsw_0e(bool is_write, uint_fast16_t address, uint_fast8_t data) {
    if(is_write)
        soft_altcharset = false;
}

static void shadow_softsw_0f(bool is_write, uint_fast16_t address, uint_fast8_t data) {
    if(is_write)
        soft_altcharset = true;
}

static void shadow_softsw_21(bool is_write, uint_fast16_t address, uint_fast8_t data) {
    if(is_write) {
        if(data & 0x80) {
            soft_monochrom = true;
        } else {
            soft_monochrom = false;
        }
    }
}

static void shadow_softsw_50(bool is_write, uint_fast16_t address, uint_fast8_t data) {
    soft_switches &= ~((uint32_t)SOFTSW_TEXT_MODE);
}

static void shadow_softsw_51(bool is_write, uint_fast16_t address, uint_fast8_t data) {
    soft_switches |= SOFTSW_TEXT_MODE;
}

static void shadow_softsw_52(bool is_write, uint_fast16_t address, uint_fast8_t data) {
    soft_switches &= ~((uint32_t)SOFTSW_MIX_MODE);
}

static void shadow_softsw_53(bool is_write, uint_fast16_t address, uint_fast8_t data) {
    soft_switches |= SOFTSW_MIX_MODE;
}

static void shadow_softsw_54(bool is_write, uint_fast16_t address, uint_fast8_t data) {
    soft_switches &= ~((uint32_t)SOFTSW_PAGE_2);
}

static void shadow_softsw_55(bool is_write, uint_fast16_t address, uint_fast8_t data) {
    soft_switches |= SOFTSW_PAGE_2;
}

static void shadow_softsw_56(bool is_write, uint_fast16_t address, uint_fast8_t data) {
    soft_switches &= ~((uint32_t)SOFTSW_HIRES_MODE);
}

static void shadow_softsw_57(bool is_write, uint_fast16_t address, uint_fast8_t data) {
    soft_switches |= SOFTSW_HIRES_MODE;
}


static void shadow_softsw_5e(bool is_write, uint_fast16_t address, uint_fast8_t data) {
    soft_dhires = true;
}

static void shadow_softsw_5f(bool is_write, uint_fast16_t address, uint_fast8_t data) {
    if(soft_dhires) {
        // This is the VIDEO7 Magic (Not documented by apple but by a patent US4631692)
        // Apple II has softswitches and also a special 2bit shift register (two flipflops basically)
        // controlled with Softwitch 80COL and AN3. AN3 is the Clock so when AN3 goes from clear to set
        // it shifts the content of 80COL into the 2 switches.
        // this is VIDEO7 Mode
        soft_video7_mode = ((soft_video7_mode & 0x01) << 1) | (soft_80col ? 0 : 1);
    }

    soft_dhires = false;
}


void abus_init() {
    // Init states
    soft_switches = SOFTSW_TEXT_MODE;


    // Setup soft-switch handlers for the Apple model
    softsw_handlers[0x21] = shadow_softsw_21;
    softsw_handlers[0x50] = shadow_softsw_50;
    softsw_handlers[0x51] = shadow_softsw_51;
    softsw_handlers[0x52] = shadow_softsw_52;
    softsw_handlers[0x53] = shadow_softsw_53;
    softsw_handlers[0x54] = shadow_softsw_54;
    softsw_handlers[0x55] = shadow_softsw_55;
    softsw_handlers[0x56] = shadow_softsw_56;
    softsw_handlers[0x57] = shadow_softsw_57;
    softsw_handlers[0x00] = shadow_softsw_00;
    softsw_handlers[0x01] = shadow_softsw_01;
    softsw_handlers[0x04] = shadow_softsw_04;
    softsw_handlers[0x05] = shadow_softsw_05;
    softsw_handlers[0x0c] = shadow_softsw_0c;
    softsw_handlers[0x0d] = shadow_softsw_0d;
    softsw_handlers[0x0e] = shadow_softsw_0e;
    softsw_handlers[0x0f] = shadow_softsw_0f;
    softsw_handlers[0x5e] = shadow_softsw_5e;
    softsw_handlers[0x5f] = shadow_softsw_5f;

    abus_main_setup(CONFIG_ABUS_PIO, ABUS_MAIN_SM);

    pio_enable_sm_mask_in_sync(CONFIG_ABUS_PIO, (1 << ABUS_MAIN_SM));
}


// Shadow parts of the Apple's memory by observing the bus write cycles
static void shadow_memory(bool is_write, uint_fast16_t address, uint32_t value) {

    if((address>=0x1000) && (address<0x6000))
    {
        if(is_write)
            main_memory[address] = value & 0xff;
    }

    if((address>=0xC000) && (address<0xC100))
    {
        // Handle shadowing of the soft switches and I/O in the range $C000 - $C0FF
        shadow_handler h = softsw_handlers[address & 0xff];
        if(h) {
                h(is_write, address, value & 0xff);
        }
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
