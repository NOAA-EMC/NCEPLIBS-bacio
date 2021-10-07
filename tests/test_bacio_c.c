/* This is a test for the NCEPLIBS-bacio project.
 *
 * This is a C test for the C code in bacio.c.
 *
 * Ed Hartnett 10/6/21
 */

#include <stdio.h>
#include <clib.h>
#include <string.h>

int bacio_(int *mode, int *start, int *newpos, int *size, int *no,
           int *nactual, int *fdes, const char *fname, char *datary,
           int  namelen, int  datanamelen);

#define ERR 99

int
main()
{
    printf("Testing NCEPLIBS-bacio. Error messages are expected during this test.\n");
    printf("Testing some simple bacio_() calls...");
    {
        int mode;
        int start = 0;
        int bad_start = 100;
        int bad_fdes = 2000;
        int newpos = 0, size = 4, no = 4, nactual, fdes;
        const char fname[] = "test_bacio_c.bin";
        const char bad_fname[] = "file_of_pure_evil.bin";
        char datary[] = "test";
        char datary_in[4];
        int  namelen, datanamelen, bad_namelen;
        int i;
        int ierr;

        namelen = strlen(fname);
        bad_namelen = strlen(bad_fname);
        datanamelen = strlen(datary);

        /* This won't work - bad mode. */
        mode = BAOPEN_WONLY | BAOPEN_RONLY;
        if ((ierr = bacio_(&mode, &start, &newpos, &size, &no, &nactual,
                           &fdes, fname, datary, namelen, datanamelen)) != 255)
            return ERR;

        /* This won't work - bad mode. */
        mode = BAREAD | BAWRITE;
        if ((ierr = bacio_(&mode, &start, &newpos, &size, &no, &nactual,
                           &fdes, fname, datary, namelen, datanamelen)) != 254)
            return ERR;
        
        /* Create the file. */
        mode = BAOPEN_WONLY;
        if ((ierr = bacio_(&mode, &start, &newpos, &size, &no, &nactual,
                           &fdes, fname, datary, namelen, datanamelen)))
            return ierr;

        /* Write some data. */
        mode = BAWRITE;
        if ((ierr = bacio_(&mode, &start, &newpos, &size, &no, &nactual,
                           &fdes, fname, datary, namelen, datanamelen)))
            return ierr;
        if (nactual != no) return ERR;


        /* Close the file. */
        mode = BACLOSE;
        if ((ierr = bacio_(&mode, &start, &newpos, &size, &no, &nactual,
                           &fdes, fname, datary, namelen, datanamelen)))
            return ierr;

        /* Try to close the file again - won't work. */
        mode = BACLOSE;
        if ((ierr = bacio_(&mode, &start, &newpos, &size, &no, &nactual,
                           &fdes, fname, datary, namelen, datanamelen)) != 247)
            return ierr;

        /* Try to reopen the file with a bad name - won't work. */
        /* This currently causes a memory leak. See: 
        /* mode = BAOPEN_RONLY; */
        /* if ((ierr = bacio_(&mode, &start, &newpos, &size, &no, &nactual, */
        /*                    &fdes, bad_fname, datary, bad_namelen, datanamelen)) != 252) */
        /*     return ierr; */

        /* Reopen the file. */
        mode = BAOPEN_RONLY;
        if ((ierr = bacio_(&mode, &start, &newpos, &size, &no, &nactual,
                           &fdes, fname, datary, namelen, datanamelen)))
            return ierr;

        /* This won't work - NULL data array. */
        mode = BAREAD;
        if ((ierr = bacio_(&mode, &start, &newpos, &size, &no, &nactual,
                           &fdes, fname, NULL, namelen, datanamelen)) != 102)
            return ERR;
        
        /* This won't work - bad fdes. */
        mode = BAREAD;
        if ((ierr = bacio_(&mode, &start, &newpos, &size, &no, &nactual,
                           &bad_fdes, fname, datary_in, namelen, datanamelen)) != 250)
            return ERR;

        /* This won't work - bad fdes. */
        mode = BAREAD;
        bad_fdes = -10;
        if ((ierr = bacio_(&mode, &start, &newpos, &size, &no, &nactual,
                           &bad_fdes, fname, datary_in, namelen, datanamelen)) != 252)
            return ERR;

        /* This won't work - seek too large. */
        mode = BAREAD;
        if ((ierr = bacio_(&mode, &bad_start, &newpos, &size, &no, &nactual,
                           &fdes, fname, datary_in, namelen, datanamelen)) != 246)
            return ERR;
        
        /* Read the data we just wrote. */
        mode = BAREAD;
        if ((ierr = bacio_(&mode, &start, &newpos, &size, &no, &nactual,
                           &fdes, fname, datary_in, namelen, datanamelen)))
            return ierr;
        if (nactual != no) return ERR;
        for (int i = 0; i < 4; i++)
            if (datary[i] != datary_in[i]) return ERR;

        /* Close the file. */
        mode = BACLOSE;
        if ((ierr = bacio_(&mode, &start, &newpos, &size, &no, &nactual,
                           &fdes, fname, datary, namelen, datanamelen)))
            return ierr;

    }
    printf("ok!\n");
    printf("Testing some other simple bacio_() calls...");
    {
        int mode;
        int start = 0;
        int bad_start = 100;
        int newpos = 0, size = 4, no = 4, nactual, fdes;
        const char fname[] = "test_bacio_c.bin";
        char datary[] = "test";
        char datary_in[8];
        int  namelen, datanamelen;
        int i;
        int ierr;

        namelen = strlen(fname);
        datanamelen = strlen(datary);

        /* Create the file. */
        mode = BAOPEN_WONLY_TRUNC;
        if ((ierr = bacio_(&mode, &start, &newpos, &size, &no, &nactual,
                           &fdes, fname, datary, namelen, datanamelen)))
            return ierr;

        /* Write some data. */
        mode = BAWRITE | NOSEEK;
        if ((ierr = bacio_(&mode, &start, &newpos, &size, &no, &nactual,
                           &fdes, fname, datary, namelen, datanamelen)))
            return ierr;
        if (nactual != no) return ERR;


        /* Close the file. It now contains "test". */
        mode = BACLOSE;
        if ((ierr = bacio_(&mode, &start, &newpos, &size, &no, &nactual,
                           &fdes, fname, datary, namelen, datanamelen)))
            return ierr;

        /* Reopen the file. */
        mode = BAOPEN_RW;
        if ((ierr = bacio_(&mode, &start, &newpos, &size, &no, &nactual,
                           &fdes, fname, datary, namelen, datanamelen)))
            return ierr;

        /* Read the data we just wrote. */
        mode = BAREAD;
        if ((ierr = bacio_(&mode, &start, &newpos, &size, &no, &nactual,
                           &fdes, fname, datary_in, namelen, datanamelen)))
            return ierr;
        if (nactual != no) return ERR;
        for (int i = 0; i < 4; i++)
            if (datary[i] != datary_in[i]) return ERR;

        /* Close the file. */
        mode = BACLOSE;
        if ((ierr = bacio_(&mode, &start, &newpos, &size, &no, &nactual,
                           &fdes, fname, datary, namelen, datanamelen)))
            return ierr;

        /* Reopen the file to append more data. */
        mode = BAOPEN_WONLY_APPEND;
        if ((ierr = bacio_(&mode, &start, &newpos, &size, &no, &nactual,
                           &fdes, fname, datary, namelen, datanamelen)))
            return ierr;

        /* Write some data. */
        mode = BAWRITE;
        start = 4;
        if ((ierr = bacio_(&mode, &start, &newpos, &size, &no, &nactual,
                           &fdes, fname, datary, namelen, datanamelen)))
            return ierr;
        if (nactual != no) return ERR;
        start = 0;

        /* Close the file. */
        mode = BACLOSE;
        if ((ierr = bacio_(&mode, &start, &newpos, &size, &no, &nactual,
                           &fdes, fname, datary, namelen, datanamelen)))
            return ierr;

        /* Reopen the file. */
        mode = BAOPEN_RONLY;
        if ((ierr = bacio_(&mode, &start, &newpos, &size, &no, &nactual,
                           &fdes, fname, datary, namelen, datanamelen)))
            return ierr;

        /* Try to Write some data - won't work, we opened read-only. */
        /* mode = BAWRITE; */
        /* if ((ierr = bacio_(&mode, &start, &newpos, &size, &no, &nactual, */
        /*                    &fdes, fname, datary, namelen, datanamelen)) != 249) */
        /*     return ierr; */

        /* Read the data we just wrote. It now contains "testtest". */
        mode = BAREAD;
        size = 8;
        no = 8;
        if ((ierr = bacio_(&mode, &start, &newpos, &size, &no, &nactual,
                           &fdes, fname, datary_in, namelen, datanamelen)))
            return ierr;
        if (nactual != no) return ERR;
        for (int i = 0; i < 4; i++)
        {
            if (datary[i] != datary_in[i]) return ERR;
            if (datary[i] != datary_in[i + 4]) return ERR;
        }

        /* Close the file. */
        mode = BACLOSE;
        if ((ierr = bacio_(&mode, &start, &newpos, &size, &no, &nactual,
                           &fdes, fname, datary, namelen, datanamelen)))
            return ierr;

    }
    printf("ok!\n");
    printf("SUCCESS!\n");
    return 0;
}
