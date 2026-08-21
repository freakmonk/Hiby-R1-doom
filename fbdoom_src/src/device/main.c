#include <stdio.h>
#include "doomdef.h"
#include "m_argv.h"
#include "d_main.h"

extern void I_InitInput(void);

int main(int argc, const char** argv)
{
    myargc = argc;
    myargv = argv;

    printf("Starting Doom on HiBy R1...\n");
    I_InitInput();

    D_DoomMain();

    return 0;
}