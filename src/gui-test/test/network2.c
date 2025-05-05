#include <iostream>
#include <fstream>
#include <vector>
#include <iterator>
#include <algorithm>
#include <string>
#include <future>
#include <cstring>
#include <sys/socket.h>
#include <netdb.h>
#include <arpa/inet.h>
#include <unistd.h>

using namespace std;

bool port_is_open(const std::string &domain, const std::string &port){

    addrinfo *result;                       // addrinfo structure to proper connection
    addrinfo hints{};                       // addrinfo structure with the type of service requested
    hints.ai_family = AF_UNSPEC;            // either IPv4 or IPv6
    hints.ai_socktype = SOCK_STREAM;        // connection-based protocol (TCP)
    char addressString[INET6_ADDRSTRLEN];   // blank address string for the ntop
    const char *retval = nullptr;           // result of the connection

    bool connection = false;

    if (0 != getaddrinfo(domain.c_str(), port.c_str(), &hints, &result)) {
        std::cout << "NjuanAlert: Invalid domain/port";
    }

    for (addrinfo *addr = result; addr != nullptr && connection == false; addr = addr->ai_next) {
        
        int handle = socket(addr->ai_family, addr->ai_socktype, addr->ai_protocol); //specific socket for this connection

        if (handle != -1 && connect(handle, addr->ai_addr, addr->ai_addrlen) == 0) {
            connection = true;
            switch(addr->ai_family) {
                case AF_INET: //IPV4
                    retval = inet_ntop(addr->ai_family, &(reinterpret_cast<sockaddr_in *>(addr->ai_addr)->sin_addr), addressString, INET6_ADDRSTRLEN);
                    break;
                case AF_INET6: //IPV6
                    retval = inet_ntop(addr->ai_family, &(reinterpret_cast<sockaddr_in6 *>(addr->ai_addr)->sin6_addr), addressString, INET6_ADDRSTRLEN);
                    break;
                default:
                    // unknown family
                    retval = nullptr;
            }
            close(handle);
        }
    }
    freeaddrinfo(result);

    return retval==nullptr ? true : false;
}
//nmap <ip>
void check_from_1_to_1000(string domain){

	for(int port=1 ; port < 1000 ; port++)
		if(port_is_open(domain, to_string(port)) == 0)
			printf("Port %d: Open\n", port);
}

//nmap -p- <ip> 
void check_from_1_to_65535(string domain){
	
	for(int port=0 ; port < 65535 ; port++)
		if(port_is_open(domain, to_string(port)) == 0)
			printf("Port %d: Open\n", port);
}

int main(int argc, char *argv[])
{
    if (argc < 2 || argc > 3)
    {
        printf ("Please enter the server IP address and range of ports to be scanned\n");
        printf ("USAGE: %s <IP> (-p-)\n", argv[0]);
        return(1);
    }
    
    string IP = argv[1];

    string ports;
    if(argc == 3)
        ports = argv[2];
        
  	printf("NJuan! :)\n");

  	//printf("argc: %d, argv[0]: %s, argv[1]: %s, argv[2]: %s\n", argc, argv[0], argv[1], argv[2]);

  	cout << "Scanning IP: "+ IP +", With option: "+ports << endl;
	
	if( ports == "-p-")
		check_from_1_to_65535(IP);
	else
		check_from_1_to_1000(IP);

  	return 0;
}