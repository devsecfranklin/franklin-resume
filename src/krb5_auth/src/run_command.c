#include <stdio.h> // popen
#include "ip_common_def.h"

const char * get_ip()
{
    // Read out "hostname -I" command output
    FILE *fd = popen("hostname -I", "r");
    if(fd == NULL) {
    fprintf(stderr, "Could not open pipe.\n");
    return NULL;
    }
    // Put output into a string (static memory)
    static char buffer[IP_BUFFER_LEN];
    fgets(buffer, IP_BUFFER_LEN, fd);

    // Only keep the first ip.
    for (int i = 0; i < IP_BUFFER_LEN; ++i)
    {
        if (buffer[i] == ' ')
        {
            buffer[i] = '\0';
            break;
        }
    }

    char *ret = malloc(strlen(buffer) + 1);
    memcpy(ret, buffer, strlen(buffer));
    ret[strlen(buffer)] = '\0';
    printf("%s\n", ret);
    return ret;
}
