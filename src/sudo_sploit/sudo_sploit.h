#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>
#include <util.h>
#include <stdarg.h>
#include <unistd.h>

#include <sys/types.h>
#include <sys/param.h>

#define MAXARGS 3

void sudo_debug(int level, const char *fmt, ...);

int main(int argc, char **argv);
