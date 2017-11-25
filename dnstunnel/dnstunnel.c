#include <grp.h>
#include <pwd.h>
#include <errno.h>
#include <regex.h>
#include <stdio.h>
#include <stdlib.h>
#include <signal.h>
#include <string.h>
#include <time.h>
#include <unistd.h>

#include <arpa/inet.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <netinet/in.h>

#include "common.h"
#include "dnstunnel.h"

int num_dns = 0;
char *dns_servers[] = { "208.67.222.222", "208.67.220.220", "208.67.222.220", "208.67.220.222" };

#define DNS_SERVERS_SIZE (sizeof(dns_servers) / sizeof(char*))

void error(char *msg)
{
    perror(msg);
    exit(1);
}

// Handle Children
/*
void reaper_handler(int signo)
{
    while(waitpid(-1, NULL, WNOHANG) > 0);
}
*/

void tcp_query(void *query, response *buffer, int len)
{
    int sockfd;
    char tmp[1024];
    
    struct sockaddr_in socks5_server;
    
    memset(&socks5_server, 0, sizeof(socks5_server));
    socks5_server.sin_family = AF_INET;
    socks5_server.sin_port = htons(SOCKS5_TOR_PORT);
    socks5_server.sin_addr.s_addr = inet_addr(LO_ADDR);
    
    if((sockfd = socket(AF_INET, SOCK_STREAM, 0)) < 0)
    {
#ifdef _DEBUG
        error("[!] Error creating TCP socket!");
#endif
    }
    
    if(connect(sockfd, (struct sockaddr*)&socks5_server, sizeof(socks5_server)) < 0)
    {
#ifdef _DEBUG
        error("[!] Error connecting to tor!");
#endif
    }
    
    // Socks handshake
    send(sockfd, "\x05\x01\x00", 3, 0);
    recv(sockfd, tmp, 1024, 0);
    
    srand(time(NULL));
    
    // Select random dns server
    in_addr_t remote_dns = inet_addr(dns_servers[rand() % (DNS_SERVERS_SIZE)]);
    memcpy(tmp, "\x05\x01\x00\x01", 4);
    memcpy(tmp + 4, &remote_dns, 4);
    memcpy(tmp + 8, "\x00\x35", 2);
    
#ifdef _DEBUG
    printf("[*] Using DNS server: %s\n", inet_ntoa(*(struct in_addr*)&remote_dns));
#endif

    send(sockfd, tmp, 10, 0);
    recv(sockfd, tmp, 1024, 0);
    
    // Forward dns query
    send(sockfd, query, len, 0);
    buffer->length = recv(sockfd, buffer->buffer, 2048, 0);
}

int *udp_listener(void)
{
    int sockfd, WRITE_RESOLVCONF = 0;
    char len, *query;
    response *buffer = (response*)malloc(sizeof(response));
    
    struct sockaddr_in dns_listener, dns_client;
    
    buffer->buffer = malloc(2048);
    
    dns_listener.sin_family = AF_INET;
    dns_listener.sin_port = htons(LISTENER_PORT);
    dns_listener.sin_addr.s_addr = inet_addr(LISTENER_ADDR);
    
    // Create our udp listener
    if((sockfd = socket(AF_INET, SOCK_DGRAM, 0)) < 0)
    {
#ifdef _DEBUG
        error("[!] Error setting up DNS proxy!");
#endif
    }
    
    if(bind(sockfd, (struct sockaddr*)&dns_listener, sizeof(dns_listener)) < 0)
    {
#ifdef _DEBUG
        error("[!] Error binding on DNS proxy!");
#endif
    }
    
#ifdef _DEBUG
    printf("[*] No errors...\n");
#endif
    
#ifdef _DEBUG
    printf("[*] Listening on %s:%d\n", LISTENER_ADDR, LISTENER_PORT);
    printf("[*] Using SOCKS5 TOR proxy: %s:%d\n", LO_ADDR, SOCKS5_TOR_PORT);
    printf("[*] Will drop priviledges to %s:%s\n", USERNAME, GROUPNAME);
#endif
    
    setuid(getpwnam(USERNAME)->pw_uid);
    setgid(getgrnam(GROUPNAME)->gr_gid);
    socklen_t dns_client_size = sizeof(struct sockaddr_in);
    
    // Setup SIGCHLD handler to kill off zombies
    /*
    struct sigaction reaper;
    memset(&reaper, 0, sizeof(struct sigaction));
    reaper.sa_handler = reaper_handler;
    sigaction(SIGCHLD, &reaper, 0);
    */
    
    while(1)
    {        
        // Receive a DNS request from the client
        len = recvfrom(sockfd, buffer->buffer, 2048, 0, (struct sockaddr*)&dns_client, &dns_client_size);
        
        // Lets not fork if recvfrom was interupted
        if(len < 0 && errno == EINTR) continue;
        
        // Other invalid values from recvfrom
        if(len < 0)
        {
#ifdef _DEBUG
            printf("[!] recvfrom failed: %s\n", strerror(errno));
#endif
            continue;
        }
        
        // Fork so we can keep receiving requests
        //if(fork() != 0) continue;
        
        // The TCP query requires the length to precede the packet, so we put the length there
        query = malloc(len + 3);
        query[0] = 0;
        query[1] = len;
        memcpy(query + 2, buffer->buffer, len);
        
        // Forward the packet to the TCP DNS server.
        tcp_query(query, buffer, len + 2);
        
        // Send the reply back to the client (minus the length at the beginning)
        sendto(sockfd, buffer->buffer + 2, buffer->length - 2, 0, (struct sockaddr*)&dns_client, sizeof(dns_client));
    }
    
    free(buffer->buffer);
    free(buffer);
    free(query);
    
    return 0;
}

void *dnstunnel_init(void *_)
{
    printf("-> dnstunnel_init()\n");
    
    if(!getpwnam(USERNAME))
    {
#ifdef _DEBUG
        printf("[!] Username (%s) does not exist! Quiting...\n", USERNAME);
#endif
        exit(1);
    }
    
    if(!getgrnam(GROUPNAME))
    {
#ifdef _DEBUG
        printf("[!] Groupname (%s) does not exist! Quiting...\n", GROUPNAME);
#endif
        exit(1);
    }
    
    return udp_listener();
}