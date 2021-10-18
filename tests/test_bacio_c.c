/* This is a test for the NCEPLIBS-bacio project.
 *
 * This is a C test for the C code in bacio.c.
 *
 * Ed Hartnett 10/6/21
 */

#include <stdio.h>
#include <clib.h>
#include <string.h>

/* Prototype for the function being tested. */
int baciol(int mode, long int start, long int newpos, int size, long int no,
           long int *nactual, int *fdes, const char *fname, void *datary);

#define ERR 99

int
main()
{
    printf("Testing NCEPLIBS-bacio. Error messages are expected during this test.\n");
    printf("Testing some simple baciol() calls...");
    {
        int mode;
        long int start = 0;
        long int bad_start = 100;
        int bad_fdes = 2000;
        long int newpos = 0, no = 4, nactual;
        int size = 4, fdes;
        const char fname[] = "test_baciol_c.bin";
        const char bad_fname[] = "file_of_pure_evil.bin";
        char datary[] = "test";
        char datary_in[4];
        int ierr;

        /* This won't work - bad mode. */
        mode = BAOPEN_WONLY | BAOPEN_RONLY;
        if ((ierr = baciol(mode, start, newpos, size, no, &nactual,
                           &fdes, fname, datary)) != 255)
            return ERR;

        /* This won't work - bad mode. */
        mode = BAREAD | BAWRITE;
        if ((ierr = baciol(mode, start, newpos, size, no, &nactual,
                           &fdes, fname, datary)) != 254)
            return ERR;
        
        /* Create the file. */
        mode = BAOPEN_WONLY;
        if ((ierr = baciol(mode, start, newpos, size, no, &nactual,
                           &fdes, fname, datary)))
            return ierr;

        /* Try to write some data - won't work, null data pointer. */
        mode = BAWRITE;
        if ((ierr = baciol(mode, start, newpos, size, no, &nactual,
                            &fdes, fname, NULL)) != 102)
            return ERR;

        /* Write some data. */
        mode = BAWRITE;
        if ((ierr = baciol(mode, start, newpos, size, no, &nactual,
                           &fdes, fname, datary)))
            return ierr;
        if (nactual != no) return ERR;

        /* Close the file. */
        mode = BACLOSE;
        if ((ierr = baciol(mode, start, newpos, size, no, &nactual,
                           &fdes, fname, datary)))
            return ierr;

        /* Try to close the file again - won't work. */
        mode = BACLOSE;
        if ((ierr = baciol(mode, start, newpos, size, no, &nactual,
                           &fdes, fname, datary)) != 247)
            return ierr;

        /* Try to reopen the file with a bad name - won't work. */
        mode = BAOPEN_RONLY;
        if ((ierr = baciol(mode, start, newpos, size, no, &nactual,
                           &fdes, bad_fname, datary)) != 252)
            return ierr;

        /* Reopen the file. */
        mode = BAOPEN_RONLY;
        if ((ierr = baciol(mode, start, newpos, size, no, &nactual,
                           &fdes, fname, datary)))
            return ierr;

        /* This won't work - NULL data array. */
        mode = BAREAD;
        if ((ierr = baciol(mode, start, newpos, size, no, &nactual,
                           &fdes, fname, NULL)) != 102)
            return ERR;
        
        /* This won't work - bad fdes. */
        mode = BAREAD;
        if ((ierr = baciol(mode, start, newpos, size, no, &nactual,
                           &bad_fdes, fname, datary_in)) != 250)
            return ERR;

        /* This won't work - another bad fdes. */
        mode = BAREAD;
        bad_fdes = -10;
        if ((ierr = baciol(mode, start, newpos, size, no, &nactual,
                           &bad_fdes, fname, datary_in)) != 252)
            return ERR;

        /* This won't work - seek too large. */
        mode = BAREAD;
        if ((ierr = baciol(mode, bad_start, newpos, size, no, &nactual,
                           &fdes, fname, datary_in)) != 246)
            return ERR;

        /* Try to write some data - won't work, we opened read-only.
         * - This error can only be reached if we open and write in
         * the same operation - which can't be done from the Fortran API ;-). */
        /* mode = BAWRITE; */
        /* if ((ierr = baciol(mode, start, newpos, size, no, &nactual, */
        /*                    &fdes, fname, datary)) != 249) */
        /*     return ierr; */
        
        /* Read the data we just wrote. */
        mode = BAREAD;
        if ((ierr = baciol(mode, start, newpos, size, no, &nactual,
                           &fdes, fname, datary_in)))
            return ierr;
        if (nactual != no) return ERR;
        for (int i = 0; i < 4; i++)
            if (datary[i] != datary_in[i]) return ERR;

        /* Close the file. */
        mode = BACLOSE;
        if ((ierr = baciol(mode, start, newpos, size, no, &nactual,
                           &fdes, fname, datary)))
            return ierr;

    }
    printf("ok!\n");
    printf("Testing some other simple baciol() calls...");
    {
        int mode;
        long int start = 0;
        long int newpos = 0, no = 4, nactual;
        int size = 4, fdes;
        const char fname[] = "test_baciolc.bin";
        char datary[] = "test";
        char datary_in[8];
        int ierr;

        /* Create the file. */
        mode = BAOPEN_WONLY_TRUNC;
        if ((ierr = baciol(mode, start, newpos, size, no, &nactual,
                           &fdes, fname, datary)))
            return ierr;

        /* Write some data. */
        mode = BAWRITE | NOSEEK;
        if ((ierr = baciol(mode, start, newpos, size, no, &nactual,
                           &fdes, fname, datary)))
            return ierr;
        if (nactual != no) return ERR;


        /* Close the file. It now contains "test". */
        mode = BACLOSE;
        if ((ierr = baciol(mode, start, newpos, size, no, &nactual,
                           &fdes, fname, datary)))
            return ierr;

        /* Reopen the file. */
        mode = BAOPEN_RW;
        if ((ierr = baciol(mode, start, newpos, size, no, &nactual,
                           &fdes, fname, datary)))
            return ierr;

        /* Read the data we just wrote. */
        mode = BAREAD;
        if ((ierr = baciol(mode, start, newpos, size, no, &nactual,
                           &fdes, fname, datary_in)))
            return ierr;
        if (nactual != no) return ERR;
        for (int i = 0; i < 4; i++)
            if (datary[i] != datary_in[i]) return ERR;

        /* Close the file. */
        mode = BACLOSE;
        if ((ierr = baciol(mode, start, newpos, size, no, &nactual,
                           &fdes, fname, datary)))
            return ierr;

        /* Reopen the file to append more data. */
        mode = BAOPEN_WONLY_APPEND;
        if ((ierr = baciol(mode, start, newpos, size, no, &nactual,
                           &fdes, fname, datary)))
            return ierr;

        /* Write some data. */
        mode = BAWRITE;
        start = 4;
        if ((ierr = baciol(mode, start, newpos, size, no, &nactual,
                           &fdes, fname, datary)))
            return ierr;
        if (nactual != no) return ERR;
        start = 0;

        /* Close the file. */
        mode = BACLOSE;
        if ((ierr = baciol(mode, start, newpos, size, no, &nactual,
                           &fdes, fname, datary)))
            return ierr;

        /* Reopen the file. */
        mode = BAOPEN_RONLY;
        if ((ierr = baciol(mode, start, newpos, size, no, &nactual,
                           &fdes, fname, datary)))
            return ierr;

        /* Read the data we just wrote. It now contains "testtest". */
        mode = BAREAD;
        size = 8;
        no = 8;
        if ((ierr = baciol(mode, start, newpos, size, no, &nactual,
                           &fdes, fname, datary_in)))
            return ierr;
        if (nactual != no) return ERR;
        for (int i = 0; i < 4; i++)
        {
            if (datary[i] != datary_in[i]) return ERR;
            if (datary[i] != datary_in[i + 4]) return ERR;
        }

        /* Close the file. */
        mode = BACLOSE;
        if ((ierr = baciol(mode, start, newpos, size, no, &nactual,
                           &fdes, fname, datary)))
            return ierr;

    }
    printf("ok!\n");
    printf("SUCCESS!\n");
    return 0;
}
