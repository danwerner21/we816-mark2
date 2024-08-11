#pragma once

#include <stdint.h>
#include <stdbool.h>


extern volatile bool soft_80col;
extern volatile bool soft_page2;
extern volatile bool soft_lores;
extern volatile bool soft_dlores;
extern volatile bool soft_hires;
extern volatile bool soft_dhires;
extern volatile bool soft_text;
extern volatile bool soft_mixed;
extern volatile bool soft_qhires;
extern volatile bool soft_mhires;

extern volatile bool soft_scanline_emulation;

#define CHARACTER_ROM_SIZE 2048

extern uint8_t character_rom[CHARACTER_ROM_SIZE];

extern uint8_t main_memory[48 * 1024];
extern uint8_t *text_mainmem_page1;
extern uint8_t *text_mainmem_page2;
extern uint8_t *hires_mainmem_page1;
extern uint8_t *hires_mainmem_page2;
