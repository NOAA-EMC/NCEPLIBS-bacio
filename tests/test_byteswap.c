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

/* Prototypes of functions we are testing here. */
int fast_byteswap(void *data,int bytes,size_t count);
void fast_byteswap_errors(int flag);

int
main()
{
    printf("Testing NCEPLIBS-bacio byteswaping.\n");
    printf("Testing some simple fast_byteswap() calls...");
    {
        short int short_data = 42;
        int int_data = 42;
        long long int int64_data = 42;
        int ret;
        
        /* Turn off error messages. */
        fast_byteswap_errors(0);

        /* Swap a short. */
        if ((ret = fast_byteswap(&short_data, 2, 1)) != 1)
            return ERR;
        if (short_data != 10752) return ERR;
        /* printf("short_data = %4.4x\n", short_data); */
        
        /* Swap an int. */
        if ((ret = fast_byteswap(&int_data, 4, 1)) != 1)
            return ERR;
        if (int_data != 704643072) return ERR;
        /* printf("int_data = %8.8x\n", int_data); */
        
        /* Swap an int64. */
        if ((ret = fast_byteswap(&int64_data, 4, 1)) != 1)
            return ERR;
        if (int64_data != 704643072) return ERR;
        
    }
    printf("ok!\n");
    printf("SUCCESS!\n");
    return 0;
}
