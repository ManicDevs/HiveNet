#define _GNU_SOURCE
#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include "common.h"
#include "torinstance.h"
#include "dnstunnel.h"

volatile bool running = true;
volatile bool torinst_running = false;

static pthread_t main_thrd, torinst_thrd, dnstun_thrd;

int hivenet_init(int argc, char *argv[])
{
    int pret = 0, ret = 0;
    
    printf("-> hivenet_init()\n");
    
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
        printf("Main thread\n");
        
        if(!torinst_running)
        {
            if((pret = pthread_create(&torinst_thrd, NULL, torinstance_init, NULL)) != 0)
            {
#ifdef _DEBUG
                printf(" [!] Error: pthread_create failure!\n");
#endif
                return pret;
            }
            torinst_running = true;
        }
        
        sleep(1);
    }
    
#ifdef _DEBUG
    printf("EXIT Main ThreadID: %d\n", pthread_self());
#endif
    
    return ret;
}

int main(int argc, char *argv[])
{
#ifndef _DEBUG
    int i;
    
    struct sigaction sigact;
    
    sigact.sa_flags = 0;
    sigact.sa_handler = SIG_IGN;
    sigemptyset(&sigact.sa_mask);
    for(i = 1; i < 65; i++)
    {
        if((i != SIGKILL) && (i != SIGSTOP) && (i != 11) && (i != 32) && (i != 33))
            assert(sigaction(i, &sigact, NULL) == 0);
    }
#endif
    
    return hivenet_init(argc, argv);
}
