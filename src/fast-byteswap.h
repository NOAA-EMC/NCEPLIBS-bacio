/** @file
 * @brief Header file for byteswap functions.
 */

#ifndef __FAST_BYTESWAP_H__
#define __FAST_BYTESWAP_H__

#include <stdlib.h>

#ifdef __cplusplus
extern "C" {
#endif

    void fast_byteswap_errors(int flag);
    int fast_byteswap(void *data,int bytes,size_t count);

#ifdef __cplusplus
}
#endif

#endif /* ifndef __FAST_BYTESWAP_H__ */
