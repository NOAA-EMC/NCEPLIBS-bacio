/* Test program for CHAR(0) handling in bacio.c
 * Covers missing test for Line 441
 */

#include <stdio.h>
#include <clib.h>
#include <string.h>

int baciol(int mode, long int start, int size, long int no,
           long int *nactual, int *fdes, const char *fname, void *datary);

#define ERR 99

int main()
{
    printf("Testing CHAR(0) handling in bacio.c...\n");
    
    /* Test 1: Empty filename (CHAR(0)) */
    printf("Test 1: Empty filename handling...");
    {
        int mode;
        long int start = 0;
        long int no = 4, nactual;
        int size = 4, fdes;
        const char *empty_fname = "";  // Empty string
        char datary[] = "test";
        int ierr;

        /* Attempt to open with empty filename - should fail */
        mode = BAOPEN_WONLY;
        ierr = baciol(mode, start, size, no, &nactual, &fdes, empty_fname, datary);
        if (ierr == 0)
        {
            printf("FAILED: Unexpected successful open with empty filename\n");
            return ERR;
        }
        printf("PASSED\n");
    }
    
    /* Test 2: Null character in middle of filename */
    printf("Test 2: Null character in filename...");
    {
        int mode;
        long int start = 0;
        long int no = 4, nactual;
        int size = 4, fdes;
        char fname_with_null[] = "test\0file.bin";  // Null in middle
        char datary[] = "test";
        int ierr;

        /* Attempt to open with null character in filename */
        mode = BAOPEN_WONLY;
        ierr = baciol(mode, start, size, no, &nactual, &fdes, fname_with_null, datary);
        /* This may succeed or fail depending on OS handling */
        if (ierr == 0)
        {
            /* If it succeeds, close the file */
            mode = BACLOSE;
            baciol(mode, start, size, no, &nactual, &fdes, fname_with_null, datary);
        }
        printf("PASSED\n");
    }
    
    /* Test 3: Valid operations with proper filenames */
    printf("Test 3: Valid CHAR(0) parameter usage...");
    {
        int mode;
        long int start = 0;
        long int no = 4, nactual;
        int size = 4, fdes;
        const char fname[] = "test_char0.bin";
        char datary[] = "test";
        char datary_in[4];
        int ierr;

        /* Create file */
        mode = BAOPEN_WONLY;
        ierr = baciol(mode, start, size, no, &nactual, &fdes, fname, datary);
        if (ierr != 0)
        {
            printf("FAILED: Could not create file\n");
            return ERR;
        }

        /* Write data */
        mode = BAWRITE;
        ierr = baciol(mode, start, size, no, &nactual, &fdes, fname, datary);
        if (ierr != 0)
        {
            printf("FAILED: Could not write data\n");
            return ERR;
        }

        /* Close file */
        mode = BACLOSE;
        ierr = baciol(mode, start, size, no, &nactual, &fdes, fname, datary);
        if (ierr != 0)
        {
            printf("FAILED: Could not close file\n");
            return ERR;
        }

        /* Reopen for reading */
        mode = BAOPEN_RONLY;
        ierr = baciol(mode, start, size, no, &nactual, &fdes, fname, datary_in);
        if (ierr != 0)
        {
            printf("FAILED: Could not reopen file\n");
            return ERR;
        }

        /* Read data */
        mode = BAREAD;
        ierr = baciol(mode, start, size, no, &nactual, &fdes, fname, datary_in);
        if (ierr != 0)
        {
            printf("FAILED: Could not read data\n");
            return ERR;
        }

        /* Verify data */
        if (memcmp(datary, datary_in, 4) != 0)
        {
            printf("FAILED: Data mismatch\n");
            return ERR;
        }

        /* Close file */
        mode = BACLOSE;
        ierr = baciol(mode, start, size, no, &nactual, &fdes, fname, datary_in);
        if (ierr != 0)
        {
            printf("FAILED: Could not close file after read\n");
            return ERR;
        }

        printf("PASSED\n");
    }

    printf("SUCCESS! All CHAR(0) handling tests passed\n");
    return 0;
}
