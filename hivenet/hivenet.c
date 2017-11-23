#include <stdio.h>

#include "torinstance.h"
#include "dnstunnel.h"

int hivenet_init(int argc, char *argv[])
{
    int ret = 0;
    
    printf("-> hivenet_init()\n");
    
    ret += torinstance_init(argc, argv);
    ret += dnstunnel_init(argc, argv);
    
    printf("Hello: %d\n", ret);
    
    return ret;
}

int main(int argc, char *argv[])
{
    return hivenet_init(argc, argv);
}
