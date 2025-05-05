#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netinet/ip_icmp.h>
#include <arpa/inet.h>
#include <netdb.h>
#include <errno.h>
#include <time.h>

#define PACKET_SIZE 64
#define MAX_WAIT_TIME 5
#define MAX_NO_PACKETS 3

unsigned short calculate_checksum(unsigned short *buffer, int length) {
    unsigned long sum = 0;
    while (length > 1) {
        sum += *buffer++;
        length -= 2;
    }
    if (length == 1) {
        sum += *(unsigned char*)buffer;
    }
    sum = (sum >> 16) + (sum & 0xffff);
    sum += (sum >> 16);
    return (unsigned short)(~sum);
}

void send_ping(int socket_fd, struct sockaddr_in *destination_addr, int sequence_number) {
    char packet[PACKET_SIZE];
    struct icmphdr *icmp_header = (struct icmphdr *)packet;
    icmp_header->type = ICMP_ECHO;
    icmp_header->code = 0;
    icmp_header->un.echo.id = getpid();
    icmp_header->un.echo.sequence = sequence_number;
    memset(packet + sizeof(struct icmphdr), 0, PACKET_SIZE - sizeof(struct icmphdr));
    icmp_header->checksum = calculate_checksum((unsigned short *)packet, PACKET_SIZE);

    if (sendto(socket_fd, packet, PACKET_SIZE, 0, (struct sockaddr *)destination_addr, sizeof(*destination_addr)) < 0) {
        perror("Error sending ping");
    }
}

int receive_ping(int socket_fd, struct sockaddr_in *source_addr) {
    char packet[PACKET_SIZE];
    socklen_t addr_len = sizeof(*source_addr);
    struct icmphdr *icmp_header = (struct icmphdr *)(packet + sizeof(struct ip));
    struct timeval timeout;
    fd_set read_fds;

    FD_ZERO(&read_fds);
    FD_SET(socket_fd, &read_fds);

    timeout.tv_sec = MAX_WAIT_TIME;
    timeout.tv_usec = 0;

    if (select(socket_fd + 1, &read_fds, NULL, NULL, &timeout) <= 0) {
        return -1;
    }
    if (recvfrom(socket_fd, packet, PACKET_SIZE, 0, (struct sockaddr *)source_addr, &addr_len) < 0) {
        perror("Error receiving ping");
        return -1;
    }

    return icmp_header->un.echo.sequence;
}

int main(int argc, char *argv[]) {
    if (argc != 2) {
        fprintf(stderr, "Usage: %s <hostname or IP address>\n", argv[0]);
        return 1;
    }

    int socket_fd = socket(AF_INET, SOCK_RAW, IPPROTO_ICMP);
    if (socket_fd < 0) {
        perror("Error creating socket");
        return 1;
    }

    struct sockaddr_in destination_addr;
    memset(&destination_addr, 0, sizeof(destination_addr));
    destination_addr.sin_family = AF_INET;

    if (inet_pton(AF_INET, argv[1], &destination_addr.sin_addr) <= 0) {
        struct hostent *host = gethostbyname(argv[1]);
        if (!host) {
            fprintf(stderr, "Error resolving hostname: %s\n", hstrerror(h_errno));
            close(socket_fd);
            return 1;
        }
        memcpy(&destination_addr.sin_addr, host->h_addr_list[0], host->h_length);
    }

    printf("Pinging %s (%s) with %d bytes of data:\n", argv[1], inet_ntoa(destination_addr.sin_addr), PACKET_SIZE);
    for (int i = 0; i < MAX_NO_PACKETS; i++) {
        send_ping(socket_fd, &destination_addr, i + 1);
        struct sockaddr_in source_addr;
        int received_sequence = receive_ping(socket_fd, &source_addr);
        if (received_sequence != -1) {
            printf("Reply from %s: icmp_seq=%d ttl=64 time=%.3f ms\n",
                   inet_ntoa(source_addr.sin_addr), received_sequence, (double)MAX_WAIT_TIME);
        } else {
            printf("Request timed out for icmp_seq=%d\n", i + 1);
        }
        sleep(1);
    }

    close(socket_fd);
    return 0;
}