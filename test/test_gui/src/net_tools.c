#include "/home/franklin/workspace/lab-franklin/src/gui-test/include/net_tools.h"
 
int ping_host(char ip_address[100]) {
    
    int pipe_arr[2];
    char buf[BUFLEN];

    //Create pipe - pipe_arr[0] is "reading end", pipe_arr[1] is "writing end"
    pipe(pipe_arr);

    if(fork() == 0) //child
    {
        dup2(pipe_arr[1], STDOUT_FILENO);
        execl("/sbin/ping", "ping", "-c 1", ip_address, (char*)NULL);
        // if execl returns nothing, success. -1 indicates failure
        //printf("ping a ling: %s\n", ip_address);
    }
    else //parent
    {
        wait(NULL);
        read(pipe_arr[0], buf, BUFLEN);
        printf("SOMETHING: %s\n", buf);

    }

    close(pipe_arr[0]);
    close(pipe_arr[1]);
    return 0;
}

int hostname_and_ip()
{
    char hostname[100];
    struct hostent *host_entry;
    int i;

    //printf("Enter hostname: ");
    //scanf("%s", hostname);

    host_entry = gethostbyname("node0");

    if (host_entry == NULL) {
        perror("gethostbyname");
        return 1;
    }

    printf("Official Host Name: %s\n", host_entry->h_name);
    printf("IP Addresses:\n");

    for (i = 0; host_entry->h_addr_list[i] != NULL; i++) {
        printf("  %s\n", inet_ntoa(*(struct in_addr*)host_entry->h_addr_list[i]));
    }

    return 0;
}
