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

#include <stdlib.h>

/* IO-related (bacio.c, banio.c). */
#define BAOPEN_RONLY              1 /**< Open file read only. */
#define BAOPEN_WONLY              2 /**< Open or create file for Write only. */
#define BAOPEN_RW                 4 /**< Open or create file for read/write. */
#define BACLOSE                   8 /**< Close an open file. */
#define BAREAD                   16 /**< Read from an open file. */
#define BAWRITE                  32 /**< Write to an open file. */
#define NOSEEK                   64 /**< No seek ignore start parameter and do not call lseek(). */
#define BAOPEN_WONLY_TRUNC      128 /**< Open or create a file for write only, truncating existing contents. */
#define BAOPEN_WONLY_APPEND     256 /**< Open or create a file for write only append. */
