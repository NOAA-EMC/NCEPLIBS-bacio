/** @file
 *     Include file to define variables for Fortran to C interface(s) 
 *     revision history.                               
 *
 * ### Program History Log
 * Date | Programmer | Comments
 * -----|------------|--------- 
 * 16 March 1998 | Robert Grumbine | Initial.
 * 25 March 1998 | Robert Grumbine | NOSEEK added
 * 20 April 1998 | Robert Grumbine | CRAY compatibility added
 * Aug 2012 | Jun Wang | move system definition to makefile as a compiler option 
 */

/* The following line should be either undef or define VERBOSE. The
 * latter gives noisy debugging output, while the former relies solely
 * on the return codes. */
#undef  VERBOSE

#include <stdlib.h>

/* IO-related (bacio.c, banio.c). */
#define BAOPEN_RONLY              1 /**< Read only. */
#define BAOPEN_WONLY              2 /**< Write only. */
#define BAOPEN_RW                 4 /**< Read/write. */
#define BACLOSE                   8 /**< Close. */
#define BAREAD                   16 /**< Read. */
#define BAWRITE                  32 /**< Write. */
#define NOSEEK                   64 /**< No seek. */
#define BAOPEN_WONLY_TRUNC      128 /**< Write only truncate. */
#define BAOPEN_WONLY_APPEND     256 /**< Write only append. */
