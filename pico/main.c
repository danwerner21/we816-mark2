#include <pico/stdlib.h>
#include <pico/multicore.h>
#include "abus.h"
#include "board_config.h"
#include "config.h"
#include "render.h"
#include "vga.h"
#include "buffers.h"


static void core1_main() {
    vga_init();
    render_loop();
}

static inline bool set_sys_clock_khz(uint32_t freq_khz, bool required) {
    uint vco, postdiv1, postdiv2;
    if (check_sys_clock_khz(freq_khz, &vco, &postdiv1, &postdiv2)) {
        set_sys_clock_pll(vco, postdiv1, postdiv2);
        return true;
    } else if (required) {
        panic("System clock of %u kHz cannot be exactly achieved", freq_khz);
    }
    return false;
}

int main() {
    // Adjust system clock for better dividing into other clocks
    set_sys_clock_khz(CONFIG_SYSCLOCK * 1000, true);

    // Setup the on-board LED for debugging
    gpio_init(PICO_DEFAULT_LED_PIN);
    gpio_set_dir(PICO_DEFAULT_LED_PIN, GPIO_OUT);

    config_load();

    multicore_launch_core1(core1_main);

    abus_init();
    abus_loop();
}
