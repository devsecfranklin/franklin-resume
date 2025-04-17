#include <stdio.h>
#include <stdlib.h>

int main() {
    char ip_address[20];
    int result;

    printf("Enter the IP address to ping: ");
    scanf("%s", ip_address);

    char command[50];
    sprintf(command, "ping -c 4 %s", ip_address);

    result = system(command);

    if (result == 0) {
        printf("Ping successful.\n");
    } else {
        printf("Ping failed.\n");
    }

    return 0;
}