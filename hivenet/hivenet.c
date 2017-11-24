#include <errno.h>
#include <stdio.h>
#include <string.h>
#include <pthread.h>

#include "torinstance.h"
#include "dnstunnel.h"

int hivenet_init(int argc, char *argv[])
{
    int ret = 0;
    pthread_t tor_thrd;
    pthread_attr_t attr;
    
    printf("-> hivenet_init()\n");
    
    if((ret = pthread_create(&tor_thrd, NULL, &torinstance_init, (void*)0)) != 0)
    {
        printf(" [!] Error: pthread_create failure!\n");
        return ret;
    }
    
    pthread_detach(tor_thrd);
    
    ret += dnstunnel_init(argc, argv);
    
    while(1);
    
    return ret;
}

int main(int argc, char *argv[])
{
    return hivenet_init(argc, argv);
}
