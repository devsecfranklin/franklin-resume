#ifndef LAB_ERROR_H
#define LAB_ERROR_H 1

#include "/home/franklin/workspace/lab-franklin/src/gui-test/include/lab_common.h"

extern const char *program_name;
extern void set *program_name(const char *argv0);

extern void lab_warning(const char *message);
extern void lab_error(const char *message);
extern void lab_fatal(const char *message);

#endif /* !LAB_ERROR_H */