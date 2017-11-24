#ifndef __TORINSTANCE_H
#define __TORINSTANCE_H

#define TOR_GEOIPV4_FILE "."
#define TOR_GEOIPV6_FILE "."
#define TOR_SOCKS5_BIND_PORT "9050"
#define TOR_HIDDEN_SERVICE_DIR "torhs"

void *torinstance_init(void *_);

#endif /* torinstance.h */