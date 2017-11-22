#ifndef __DNSTUNNEL_H
#define __DNSTUNNEL_H

typedef struct
{
    int length;
    char *buffer;
} response;

int dnstunnel_init(int argc, char *argv[]);

#endif /* dnstunnel.h */