#ifndef NET_TOOLS_H
#define NET_TOOLS_H 1

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#if defined(__linux__)
#include <netdb.h>
#include <netinet/in.h> 
#include <sys/socket.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <arpa/inet.h>
#include <unistd.h>

#elif defined(_WIN32)
#include <winsock2.h>
#include <ws2tcpip.h>
#endif

#define BUFLEN 1024

char ip_address[100];
char command[150];
int status, status2;

int ping_host(char ip_address[100]); 

#endif /* !NET_TOOLS_H */
