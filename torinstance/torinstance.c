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
    int argc = 4;
    char *argv[argc];
    
    printf("-> torinstance_init()\n");
    
    argv[1] = "--quiet";
    argv[2] = "--SocksPort";
    argv[3] = "9050";
    argv[4] = "--HiddenServiceDir";
    argv[5] = "./001";
    argv[6] = "--HiddenServicePort";
    argv[7] = "80 127.0.0.1:80";
    
    tor_main_configuration_t *cfg = tor_main_configuration_new();
    tor_main_configuration_set_command_line(cfg, argc, argv);
    tor_run_main(cfg);
    tor_main_configuration_free(cfg);
    
    return 0;
}
