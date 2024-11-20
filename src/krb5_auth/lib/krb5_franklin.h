#ifndef _KRB5_FRANKLIN_H
#define _KRB5_FRANKLIN_H

gss_name_t get_spn(char *spn);
char* init_sec_context(char *spn);

#endif // _KRB5_FRANKLIN_H
