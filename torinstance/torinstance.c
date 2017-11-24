#if __STDC_VERSION__ >= 199901L
#define _XOPEN_SOURCE 600
#else
#define _XOPEN_SOURCE 500
#endif /* __STDC_VERSION__ */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include <or/tor_api.h>

#include "torinstance.h"

char *TOR_HIDDEN_SERVICE_PORTS[] =
{
    "8080 127.0.0.1:8080"
};

#define TOR_HIDDEN_SERVICE_PORTS_SIZE (sizeof(TOR_HIDDEN_SERVICE_PORTS) / sizeof(char*))

void *torinstance_init(void *_)
{
    int i, argc = 10; // argv[*]'s below + TOR_HIDDEN_SERVICE_PORTS_SIZE +- 1
    char *argv[] = {};
    
    printf("-> torinstance_init()\n");
    
    argv[0] = "/";
    argv[1] = "--ignore-missing-torrc";
    argv[2] = "--GeoIPFile";
    argv[3] = TOR_GEOIPV4_FILE;
    argv[4] = "--GeoIPv6File";
    argv[5] = TOR_GEOIPV6_FILE;
    argv[6] = "--SocksPort";
    argv[7] = TOR_SOCKS5_BIND_PORT;
    argv[8] = "--HiddenServiceDir";
    argv[9] = TOR_HIDDEN_SERVICE_DIR;
    
    for(i = 0; i < TOR_HIDDEN_SERVICE_PORTS_SIZE; i++, argc++)
    {
        argv[argc] = "--HiddenServicePort";
        argc++;
        argv[argc] = TOR_HIDDEN_SERVICE_PORTS[i];
    }
    
#ifndef _DEBUG
    argc++;
    argv[argc-1] = "--quiet";
#endif
    
    tor_main_configuration_t *cfg = tor_main_configuration_new();
    tor_main_configuration_set_command_line(cfg, argc, argv);
    tor_run_main(cfg);
    tor_main_configuration_free(cfg);
    
    return 0;
}
