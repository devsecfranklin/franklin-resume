#include "sudo_sploit.h"

int debug_level = 9;

void sudo_debug(int level, const char *fmt, ...)
{
    va_list ap;
    char *fmt2;

    if (level > debug_level)
        return;

    /* Backet fmt with program name and a newline to make it a single 
    write */
    easprintf(&fmt2, "%s: %s\n", getprogname(), fmt);
    va_start(ap, fmt);
    vfprintf(stderr, fmt2, ap);
    va_end(ap);
    efree(fmt2);
}

int main (int argc, char **argv) 
{
   sudo_debug(argc, argv);
   exit(EXIT_SUCCESS);
}
