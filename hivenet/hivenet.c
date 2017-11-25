#define _POSIX_SOURCE
#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include <signal.h>

#include "common.h"
#include "torinstance.h"
#include "dnstunnel.h"

volatile bool running = true;

static pthread_t main_thrd, torinst_thrd, dnstun_thrd;

int hivenet_init(int argc, char *argv[])
{
    int pret = 0, ret = 0;
    
#ifndef _DEBUG
RECYCLE:
#endif
    
    printf("-> hivenet_init()\n");
    
    if((pret = pthread_create(&torinst_thrd, NULL, torinstance_init, NULL)) != 0)
    {
#ifdef _DEBUG
        printf(" [!] Error: pthread_create failure!\n");
#endif
        return pret;
    }
    
    ret += pret;
    
    /*
    if((pret = pthread_create(&dnstun_thrd, NULL, dnstunnel_init, NULL)) != 0)
    {
#ifdef _DEBUG
        printf(" [!] Error: pthread_create failure!\n");
#endif
        return pret;
    }
    
    ret += pret;
    
    */
    
    while(running)
    {
        if(!running)
            pthread_join(torinst_thrd, NULL);
        
        printf("Main thread\n");
        sleep(1);
    }
    
#ifndef _DEBUG
    running = true;
    goto RECYCLE;
#else
    printf("EXIT Main ThreadID: %d\n", pthread_self());
#endif
    
    return ret;
}

int main(int argc, char *argv[])
{
    return hivenet_init(argc, argv);
}
