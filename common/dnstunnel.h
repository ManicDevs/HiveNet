#ifndef __DNSTUNNEL_H
#define __DNSTUNNEL_H

typedef struct
{
    int length;
    char *buffer;
} response;

void *dnstunnel_init(void *_);

#endif /* dnstunnel.h */