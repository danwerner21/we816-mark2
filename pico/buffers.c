#include "buffers.h"

// Shadow copy of the Apple soft-switches
volatile bool soft_80col=false;
volatile bool soft_page2=false;
volatile bool soft_lores=false;
volatile bool soft_dlores=false;
volatile bool soft_hires=false;
volatile bool soft_dhires=false;
volatile bool soft_qhires=false;
volatile bool soft_mhires=false;
volatile bool soft_text=true;
volatile bool soft_mixed=false;


// Custom device soft-switches
volatile bool soft_scanline_emulation;

// The currently programmed character generator ROM for text mode
uint8_t character_rom[256 * 8];

// The lower 48K of main
uint8_t main_memory[48 * 1024];

uint8_t *text_mainmem_page1 = main_memory + 0x1000;
uint8_t *text_mainmem_page2 = main_memory + 0x2000;
uint8_t *hires_mainmem_page1 = main_memory + 0x2000;
uint8_t *hires_mainmem_page2 = main_memory + 0x6000;
