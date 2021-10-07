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
    printf("Testing NCEPLIBS-bacio.\n");
    printf("Testing some simple bacio_() calls...");
    {
        int mode;
        int start = 0;
        int bad_start = 100;
        int bad_fdes = 2000;
        int newpos = 0, size = 4, no = 4, nactual, fdes;
        const char fname[] = "test_bacio_c.bin";
        char datary[] = "test";
        char datary_in[4];
        int  namelen, datanamelen;
        int i;
        int ierr;

        namelen = strlen(fname);
        datanamelen = strlen(datary);

        /* This won't work. */
        mode = BAOPEN_WONLY | BAOPEN_RONLY;
        if ((ierr = bacio_(&mode, &start, &newpos, &size, &no, &nactual,
                           &fdes, fname, datary, namelen, datanamelen)) != 255)
            return ERR;

        /* This won't work. */
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
        char datary_in[4];
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

        /* Reopen the file. */
        mode = BAOPEN_RONLY;
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

    }
    printf("ok!\n");
    printf("SUCCESS!\n");
    return 0;
}
