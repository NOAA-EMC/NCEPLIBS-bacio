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

/* These are the mode flags for the bacio_() function. */
#define BAOPEN_RONLY              1 /**< Open file read only. */
#define BAOPEN_WONLY              2 /**< Open or create file for Write only. */
#define BAOPEN_RW                 4 /**< Open or create file for read/write. */
#define BACLOSE                   8 /**< Close an open file. */
#define BAREAD                   16 /**< Read from an open file. */
#define BAWRITE                  32 /**< Write to an open file. */
#define NOSEEK                   64 /**< No seek ignore start parameter and do not call lseek(). */
#define BAOPEN_WONLY_TRUNC      128 /**< Open or create a file for write only, truncating existing contents. */
#define BAOPEN_WONLY_APPEND     256 /**< Open or create a file for write only append. */

/* Error codes. */

#define BA_NOERROR   0   /**< No error. */
#define BA_EROANDWO  255 /**< Tried to open read only and write only. */
#define BA_ERANDW    254 /**< Tried to read and write in the same call. */
#define BA_EINTNAME  253 /**< Internal failure in name processing. */
#define BA_EFILEOPEN 252 /**< Failure in opening file. */
#define BA_ERONWO    251 /**< Tried to read on a write-only file. */
#define BA_ERNOSTART 250 /**< Failed in read to find the 'start' location. */
#define BA_EWANDRO   249 /**< Tried to write to a read only file. */
#define BA_EWNOSTART 248 /**< Failed in write to find the 'start' location. */
#define BA_ECLOSE    247 /**< Error in close. */
#define BA_EFEWDATA  246 /**< Read or wrote fewer data than requested. */
#define BA_EDATANULL 102 /**< Data pointer is NULL. */
