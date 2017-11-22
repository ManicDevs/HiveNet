#include <stdio.h>
#include <stdbool.h>
#include <stdlib.h>
#include <unistd.h>

#include "dnstunnel.h"
#include "icmpfs.h"

#include <or/tor_api.h>

int hivenet_init(int argc, char *argv[])
{
    int ret = 0;
    
    printf("-> hivenet_init()\n");
    
    ret += dnstunnel_init(argc, argv);
    
    printf("Hello\n");
    
    return ret;
}

int main(int argc, char *argv[])
{
    return hivenet_init(argc, argv);
}