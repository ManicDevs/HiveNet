#if __STDC_VERSION__ >= 199901L
#define _XOPEN_SOURCE 600
#else
#define _XOPEN_SOURCE 500
#endif /* __STDC_VERSION__ */

#include <stdio.h>

#include <or/tor_api.h>

int tor_main(int argc, char *argv[]);

int torinstance_init(int argc, char *argv[])
{
    printf("-> torinstance_init()\n");
    
    tor_main_configuration_t *cfg = tor_main_configuration_new();
    
    tor_main_configuration_set_command_line(cfg, argc, argv);
    
    printf("%d\n", tor_run_main(cfg));
    
    tor_main_configuration_free(cfg);
    
    return 0;
}
