#include "render.h"
#include "buffers.h"



void render_loop() {
    while(1) {
        if(!soft_mixed & soft_lores)
            render_lores();
        if(soft_mixed & soft_lores)
            render_mixed_lores();
        if(soft_hires)
            render_hires(soft_mixed);
        if(soft_text)
            render_text();
    }
}
