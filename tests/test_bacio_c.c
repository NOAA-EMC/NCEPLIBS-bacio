/* This is a test for the NCEPLIBS-bacio project.
 *
 * Ed Hartnett 10/6/21
 */

#include <stdio.h>
#include <clib.h>
#include <string.h>

int bacio_(int *mode, int *start, int *newpos, int *size, int *no,
           int *nactual, int *fdes, const char *fname, char *datary,
           int  namelen, int  datanamelen);

int
main()
{
    printf("Testing NCEPLIBS-bacio.\n");
    printf("Testing bacio call...");
    {
        int mode = BAOPEN_WONLY;
        int start = 0;
        int newpos = 0, size = 4, no = 1, nactual = 0, fdes = 0;
        const char fname[] = "test_bacio_c.bin";
        char datary[] = "test";
        int  namelen, datanamelen;
        int ierr;

        namelen = strlen(fname);
        datanamelen = strlen(datary);

        /* Create the file. */
        if ((ierr = bacio_(&mode, &start, &newpos, &size, &no, &nactual,
                           &fdes, fname, datary, namelen, datanamelen)))
            return ierr;

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
