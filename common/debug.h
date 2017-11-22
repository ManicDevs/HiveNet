#ifndef __DEBUG_H
#define __DEBUG_H

#include <stddef.h>

void test(void);

#ifdef DEBUG
    #include <stdio.h>
    #include <errno.h>
    
    extern int debug_lvl_;  // The current debug level, a global variable defined in main.c.
 
    void debug_print_buf(const unsigned char *buf, const size_t len);
 
    // General debug function to insert debug code
    #define D(x) x
 
    // Tracing function that displays its location if the debug level meets or exceeds the threshold
    #define DL(l)                                                                   \
        do {                                                                        \
            if(l <= debug_level_) {                                                 \
                fprintf(stdout, "%s:%d: %s()\n", __FILE__, __LINE__,__FUNCTION__);  \
                fflush(stdout);                                                     \
            }                                                                       \
        } while (0)
 
    // Debug function that displays its location and inserts code if the debug level meets or exceeds the threshold
    #define DLX(l, x)                                                               \
        do {                                                                        \
            if(l <= debug_level_) {                                                 \
                fprintf(stdout, "%s:%d: %s(): ", __FILE__, __LINE__,__FUNCTION__);  \
                x;                                                                  \
                fflush(stdout);                                                     \
            }                                                                       \
        } while (0)
 
    // Debug function to print a character buffer
    #define DPB(l, text, buf, len)                                                                                          \
        do {                                                                                                                \
            if(l <= debug_level_) {                                                                                         \
                fprintf(stdout, "%s:%d: %s(): %s (%u bytes)\n", __FILE__, __LINE__,__FUNCTION__, text, (unsigned int) len); \
                debug_print_buffer(buf, len);                                                                               \
                }                                                                                                           \
        } while (0)
#else
    #define D(x)
    #define DL(l)                   do {} while(0)
    #define DLX(l, x)               do {} while(0)
    #define DPB(l, text, buf, len)  do {} while(0)
#endif

#endif /* debug.h */