#include <psp2/kernel/processmgr.h>
#include <vita2d.h>

int main(int argc, char *argv[]) 
{
    (void)argc;
    (void)argv;

    vita2d_init_advanced_with_msaa(1024*1024, SCE_GXM_MULTISAMPLE_4X);
    auto *pgf = vita2d_load_default_pgf();

    do {
        vita2d_start_drawing();
        vita2d_clear_screen();

        //code
        vita2d_pgf_draw_textf(pgf, 10, 20, 0xFFFFFFFF, 1.0f, "%s", "zupervita");

        vita2d_end_drawing();
        vita2d_swap_buffers();

    } while(true);

    vita2d_fini();
    vita2d_free_pgf(pgf);

    sceKernelExitProcess(0);
    return 0;
}
