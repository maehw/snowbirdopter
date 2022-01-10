#include <stdint.h>

/**
 * Set the following define to 1 if to get 'play-sound.c' file.
 * Set it to 0 to get the minimal game binary 'still-works.c'.
 * The file names reference to nomeata's ARM investigations under:
 * https://github.com/nomeata/tiptoi-arm-investigation/tree/main/Europa
 */
#define DO_PLAY   0
//#define DO_PLAY   1

typedef void (*play)(short, short, char, short);

int32_t main(int32_t a1)
{
  /* !!! WARNING !!!
   * This file is probably in a work-in-progress (WIP) state
   * and will quite likely not work! Though, feel free to modify and run it.
   * !!! WARNING !!!
   */

#if DO_PLAY
    if (*(char *)(*(int32_t *)(a1 + 0x34) + 0xdec) == 0)
    {
        *(char *)(*(int32_t *)(a1 + 0x34) + 0xdec) = 1;
        *(char *)(*(int32_t *)(a1 + 0x34) + 0x58) = 100;
        return 1;
    }

    /*
    (*(void (**)())(a1 + 0x88))();
    (*(void (**)())(a1 + 0x90))();
    (*(void (**)())(a1 + 0x94))();
    */

    (*(play*)(a1 + 140))(
      **((short **)(a1 + 228)),
      **((short **)(a1 + 232)),
      **((char **)(a1 + 236)),
      **((short **)(a1 + 240))
    );

    *(int *)(*(int *)(a1 + 0x124) + 0x78) =
    *(int *)(*(int *)(a1 + 0x124) + 0x52);
#endif

    /* minimal code ('still-works.c') */
    *(char *)(*(int32_t *)(a1 + 0x34) + 0xdec) = -1;
    return 255;
}
