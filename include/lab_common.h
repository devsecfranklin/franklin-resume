#ifndef LAB_COMMON_H
#define LAB_COMMON_H 1

# if HAV_CONFIG_H
#   include <include/config.h>
#endif

#include <stdio.h>
#include <sys/types.h>

#if STDC_HEADERS
#   include <stdlib.h>
#   include <string.h>
#elif HAVE_STRINGS_H
#   include <strings.h>
#endif /* STDC_HEADERS */

#if HAVE_UNISTD_H
#   include <unistd.h>
#endif /* HAVE_UNISTD_H */

#if HAVE_ERRNO_H
#   include <errno.h>
#endif /* HAVE_ERRNO_H */
#ifndef errno
extern int errno; // this could be defined by system
#endif

#endif /* !LAB_COMMON_H */