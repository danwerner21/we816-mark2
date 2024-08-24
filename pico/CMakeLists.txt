cmake_minimum_required(VERSION 3.16)

# Pull in SDK (must be before project)
include(cmake/pico_sdk_import.cmake)

project(vga)
set(CMAKE_C_STANDARD 11)

pico_sdk_init()

add_compile_options(-Wall -Wextra -Wnull-dereference -Wno-unused-parameter -Wno-unused-function)


add_executable(vga)
pico_set_binary_type(vga copy_to_ram)
pico_set_linker_script(vga ${CMAKE_CURRENT_SOURCE_DIR}/memmap_copy_to_ram_custom.ld)

pico_generate_pio_header(vga
    ${CMAKE_CURRENT_SOURCE_DIR}/vga.pio)
pico_generate_pio_header(vga
    ${CMAKE_CURRENT_SOURCE_DIR}/abus.pio)

file(GLOB TEXTFONT_SRC_FILES textfont/*.c)
target_sources(vga PUBLIC
    main.c
    abus.c
    buffers.c
    colors.c
    config.c
    device_regs.c
    render.c
    render_hires.c
    render_lores.c
    render_text.c
    ${TEXTFONT_SRC_FILES}
    vga.c
)
target_include_directories(vga PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})
target_link_libraries(vga PUBLIC
    pico_multicore
    pico_stdlib
    hardware_dma
    hardware_flash
    hardware_pio
)

pico_add_extra_outputs(vga)

add_custom_command(TARGET vga POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy vga.uf2 ../../bin/vga.uf2
    COMMENT "Created ../../bin/vga.uf2"
)
