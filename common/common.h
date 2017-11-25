#ifndef __COMMON_H
#define __COMMON_H

#include <pthread.h>

#define USERNAME "nobody"
#define GROUPNAME "nobody"

#define LO_ADDR "127.0.0.1"
#define LISTENER_ADDR "127.0.0.1"
#define LISTENER_PORT 35353
#define SOCKS5_TOR_PORT 9050

#ifndef false
#define false 0
#endif
#ifndef true
#define true (!false)
#endif

typedef int bool;

extern volatile bool running;

void _sleep(int tosleep);

#endif /* common.h */