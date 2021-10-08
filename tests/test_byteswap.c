/* This is a test for the NCEPLIBS-bacio project.
 *
 * This is a C test for the code in byteswap.c.
 *
 * Ed Hartnett 10/8/21
 */

#include <stdio.h>
#include <clib.h>
#include <string.h>

#define ERR 99

int
main()
{
    printf("Testing NCEPLIBS-bacio byteswaping.\n");
    printf("Testing some simple fast_byteswap() calls...");
    {
        /* Turn off error messages. */
        fast_byteswap_errors(0);
    }
    printf("ok!\n");
    printf("SUCCESS!\n");
    return 0;
}
