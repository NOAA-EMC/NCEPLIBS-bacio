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
void byteswap_(char *data, int *nbyte, int *nnum);

int
main()
{
    printf("Testing NCEPLIBS-bacio byteswaping. Expect error messages.\n");
    printf("Testing some simple fast_byteswap() calls...");
    {
        unsigned char byte_data = 42;
        short int short_data = 42;
        int int_data = 42;
        long long int int64_data = 42;
        int ret;
        
        /* Turn off error messages. */
        fast_byteswap_errors(0);

        /* Swap a byte. Does nothing. */
        if ((ret = fast_byteswap(&byte_data, 1, 1)) != 1)
            return ERR;
        
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

        /* Swap a weird number and it won't work. */
        if ((ret = fast_byteswap(&short_data, 3, 1)) != 0)
            return ERR;
    }
    printf("ok!\n");
    printf("Testing some byteswap_() calls...");
    {
        short int short_data = 42;
        int int_data = 42;
        long long int int64_data = 42;
        int nbyte, nnum = 1;
        int ret;
        
        /* Turn off error messages. */
        fast_byteswap_errors(0);

        /* Swap a short. */
        nbyte = 2;
        byteswap_((char *)&short_data, &nbyte, &nnum);
        if (short_data != 10752) return ERR;
        /* printf("short_data = %4.4x\n", short_data); */
        
        /* Swap an int. */
        nbyte = 4;
        byteswap_((char *)&int_data, &nbyte, &nnum);
        if (int_data != 704643072) return ERR;
        /* printf("int_data = %8.8x\n", int_data); */
        
        /* Swap an int64. */
        nbyte = 8;
        byteswap_((char *)&int64_data, &nbyte, &nnum);
        /* printf("int64_data = %lld\n", int64_data);         */
        if (int64_data != 3026418949592973312LL) return ERR;
        
    }
    printf("ok!\n");
    printf("Testing some non-aligned byteswap_() calls...");
    {
        int e;

        /* Try with and without error messages turned on. */
        for (e = 0; e < 2; e++)
        {
            short int short_data[2] = {42, 42};
            int int_data[2] = {42, 42};
            long long int int64_data[2] = {42, 42};
            void *ptr;
            int nbyte, nnum = 1;
            
            /* Turn off error messages. */
            fast_byteswap_errors(e);

            /* Swap a short. */
            nbyte = 2;
            ptr = short_data;
            ptr = (char *)ptr + 1;
            byteswap_(ptr, &nbyte, &nnum);
            if (short_data[0] != 10794 || short_data[1] != 0) return ERR;
            
            /* Swap an int. */
            nbyte = 4;
            ptr = int_data;
            ptr = (char *)ptr + 1;
            byteswap_(ptr, &nbyte, &nnum);
            if (int_data[0] != 10794 || int_data[1] != 0) return ERR;
        
            /* Swap an int64. */
            nbyte = 8;
            ptr = int64_data;
            ptr = (char *)ptr + 1;
            byteswap_(ptr, &nbyte, &nnum);
            if (int64_data[0] != 10794 || int64_data[1] != 0) return ERR;
        }
    }
    printf("ok!\n");
    printf("SUCCESS!\n");
    return 0;
}
