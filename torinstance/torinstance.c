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

void *torinstance_init(void *_)
{
    int argc = 13; // argv[0] + argv[*]'s below + 1
#ifdef _DEBUG
    argc--;
#endif
    char *argv[argc];
    
    printf("-> torinstance_init()\n");
    
    argv[1] = "--SocksPort";
    argv[2] = "9050";
    argv[3] = "--ignore-missing-torrc";
    argv[4] = "--GeoIPFile";
    argv[5] = ".";
    argv[6] = "--GeoIPv6File";
    argv[7] = ".";
    argv[8] = "--HiddenServiceDir";
    argv[9] = "torhs";
    argv[10] = "--HiddenServicePort";
    argv[11] = "80 127.0.0.1:80";
#ifndef _DEBUG
    argv[argc-1] = "--quiet";
#endif

    tor_main_configuration_t *cfg = tor_main_configuration_new();
    tor_main_configuration_set_command_line(cfg, argc, argv);
    tor_run_main(cfg);
    tor_main_configuration_free(cfg);
    
    return 0;
}
