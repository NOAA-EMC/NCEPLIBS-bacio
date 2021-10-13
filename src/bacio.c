/** @file
 * @brief Fortran-callable routines to read and write characther
 * data byte addressably.
 *
 *  v1.1:
 * - Put diagnostic output under control of define VERBOSE or QUIET
 * - Add option of non-seeking read/write
 * - Return code for fewer data read/written than requested
 *
 *  v1.2:
 * - Add cray compatibility  20 April 1998  Robert Grumbine
 *
 *  v1.3:
 * - Add IBMSP compatibility (IBM4, IBM8)
 * - Add modes BAOPEN_WONLY_TRUNC, BAOPEN_WONLY_APPEND
 * - Use isgraph instead of isalnum + a short list of accepted characters
 * for filename check 12 Dec 2000 Stephen Gilbert
 * - negative return codes are wrapped to positive, revise return codes
 * verify that banio and bacio have same contents, update comments
 * 29 Oct 2008 Robert Grumbine
 *
 *  v1.4:
 * - 21 Nov 2008 Add baciol and baniol functions, versions to work with files
 * over 2 Gb Robert Grumbine
 * - Aug 2012 Jun Wang fix c filename length because the c string
 * needs to end with "null" terminator , and free allocated cfile
 * name realname to avoid memory leak.
 * - Sep 2012 Jun Wang: remove execute permission on the data file
 * generated by bacio.
 *
 * v2.5:
 * Oct. 2021 - Ed Hartnett - Extensive cleanup, testing, and refactor.
 *
 * @author Robert Grumbine @date 16 March 1998
 */

#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>

#include "clib.h"

/**
 * Do bacio operation, with new names for long int arguments, needed
 * for files > 2 Gb.
 *
 * @param mode integer specifying operations to be performed see the
 * clib.inc file for the values. Mode is obtained by adding together
 * the values corresponding to the operations The best method is to
 * include the clib.inc file and refer to the names for the operations
 * rather than rely on hard-coded values.
 * @param start byte number to start your operation from. 0 is the
 * first byte in the file, not 1.
 * @param newpos position in the file after a read or write has been
 * performed. You'll need this if you're doing 'seeking' read/write.
 * @param size is the size of the objects you are trying to read. Rely
 * on the values in the locale.inc file. Types are CHARACTER, INTEGER,
 * REAL, COMPLEX. Specify the correct value by using SIZEOF_type,
 * where type is one of these. (After having included the locale.inc
 * file).
 * @param no is the number of things to read or write (characters,
 * integers, whatever).
 * @param nactual is the number of things actually read or
 * written. Check that you got what you wanted.
 * @param fdes is an integer 'file descriptor'. This is not a Fortran
 * Unit Number You can use it, however, to refer to files you've
 * previously opened.
 * @param fname is the name of the file. This only needs to be defined
 * when you are opening a file. It must be (on the Fortran side)
 * declared as CHARACTER*N, where N is a length greater than or equal
 * to the length of the file name. CHARACTER*1 fname[80] (for example)
 * will fail.
 * @param datary is the name of the entity (variable, vector, array)
 * that you want to write data out from or read it in to. The fact
 * that C is declaring it to be a char * does not affect your fortran.
 * @param namelen - Length of the name.
 * @param datanamelen - Length of data. (Not used).
 *
 * This function is called from the Fortran code in baciof.f90.
 *
 * @return ::BA_NOERROR No error.
 * @return ::BA_EROANDWO Tried to open read only and write only.
 * @return ::BA_ERANDW Tried to read and write in the same call.
 * @return ::BA_EINTNAME Internal failure in name processing.
 * @return ::BA_EFILEOPEN Failure in opening file.
 * @return ::BA_ERONWO Tried to read on a write-only file.
 * @return ::BA_ERNOSTART Failed in read to find the 'start' location.
 * @return ::BA_EWANDRO Tried to write to a read only file.
 * @return ::BA_EWNOSTART Failed in write to find the 'start' location.
 * @return ::BA_ECLOSE Error in close.
 * @return ::BA_EFEWDATA Read or wrote fewer data than requested.
 * @return ::BA_EDATANULL Data pointer is NULL.
 *
 * @author Robert Grumbine @date 21 November 2008
 */
int
baciol_(int *mode, long int *start, long int *newpos, int *size, long int *no,
        long int *nactual, int *fdes, const char *fname, char *datary,
        int namelen, int datanamelen)
{
    int i, jret, seekret;
    char *realname = NULL;
    size_t count;

    /* Initialization(s) */
    *nactual = 0;

    /* Check for illegal combinations of options */
    if ((BAOPEN_RONLY & *mode) &&
        ((BAOPEN_WONLY & *mode) || (BAOPEN_WONLY_TRUNC & *mode) || (BAOPEN_WONLY_APPEND & *mode)))
        return BA_EROANDWO;

    if ((BAREAD & *mode) && (BAWRITE & *mode)) 
        return BA_ERANDW;

    /* Copy and null terminate the filename. */
    if ((BAOPEN_RONLY & *mode) || (BAOPEN_WONLY & *mode) ||
        (BAOPEN_WONLY_TRUNC & *mode) || (BAOPEN_WONLY_APPEND & *mode) ||
        (BAOPEN_RW & *mode))
    {
        if (!(realname = (char *) malloc((namelen + 1) * sizeof(char))))
            return BA_EINTNAME;

        strncpy(realname, fname, namelen);
        realname[namelen] = '\0';
    }

    /* Open files with correct read/write and file permission. */
    if (BAOPEN_RONLY & *mode)
    {
        *fdes = open(realname, O_RDONLY , S_IRUSR | S_IRGRP | S_IROTH | S_IWUSR | S_IWGRP);
    }
    else if (BAOPEN_WONLY & *mode)
    {
        *fdes = open(realname, O_WRONLY | O_CREAT , S_IRUSR | S_IRGRP | S_IROTH | S_IWUSR | S_IWGRP);
    }
    else if (BAOPEN_WONLY_TRUNC & *mode)
    {
        *fdes = open(realname, O_WRONLY | O_CREAT | O_TRUNC , S_IRUSR | S_IRGRP | S_IROTH | S_IWUSR | S_IWGRP);
    }
    else if (BAOPEN_WONLY_APPEND & *mode)
    {
        *fdes = open(realname, O_WRONLY | O_CREAT | O_APPEND , S_IRUSR | S_IRGRP | S_IROTH | S_IWUSR | S_IWGRP);
    }
    else if (BAOPEN_RW & *mode)
    {
        *fdes = open(realname, O_RDWR | O_CREAT , S_IRUSR | S_IRGRP | S_IROTH | S_IWUSR | S_IWGRP);
    }

    /* If the file open didn't work, or a bad fdes was passed in,
     * return error. */
    if (*fdes < 0)
    {
        if (realname)
            free(realname);
        return BA_EFILEOPEN;
    }

    /* Check for bad mode flags. */
    if (BAREAD & *mode &&
        ((BAOPEN_WONLY & *mode) || (BAOPEN_WONLY_TRUNC & *mode) || (BAOPEN_WONLY_APPEND & *mode)))
        return BA_ERONWO;

    /* Read data as requested. */
    if (BAREAD & *mode )
    {
        /* Seek the right part of the file. */
        if (!(*mode & NOSEEK))
            if ((seekret = lseek(*fdes, *start, SEEK_SET)) == -1)
                return BA_ERNOSTART;

        if (datary == NULL)
        {
            printf("Massive catastrophe -- datary pointer is NULL\n");
            return BA_EDATANULL;
        }
        count = (size_t)*no;
        jret = read(*fdes, (void *)datary, count);
        *nactual = jret;
        *newpos = *start + jret;
    }

    /* Check for bad mode flag. */
    if (BAWRITE & *mode && BAOPEN_RONLY & *mode) 
        return BA_EWANDRO;
    
    /* See if we should be writing. */
    if (BAWRITE & *mode)
    {
        if (!(*mode & NOSEEK))
            if ((seekret = lseek(*fdes, *start, SEEK_SET)) == -1)
                return BA_EWNOSTART;

        if (datary == NULL)
        {
            printf("Massive catastrophe -- datary pointer is NULL\n");
            return BA_EDATANULL;
        }
        count = (size_t)*no;
        jret = write(*fdes, (void *) datary, count);
        if (jret != *no)
        {
            *nactual = jret;
            *newpos = *start + jret;
        }
        else
        {
            *nactual = jret;
            *newpos = *start + jret;
        }
    }

    /* Close file if requested */
    if (BACLOSE & *mode )
        if ((jret = close(*fdes)) != 0)
            return BA_ECLOSE;

    /* Free the realname pointer to prevent memory leak */
    if ((BAOPEN_RONLY & *mode) || (BAOPEN_WONLY & *mode) ||
         (BAOPEN_WONLY_TRUNC & *mode) || (BAOPEN_WONLY_APPEND & *mode) ||
         (BAOPEN_RW & *mode))
    {
        free(realname);
    }

    /* Check that if we were reading or writing, that we actually got
       what we expected. Return 0 (success) if we're here and weren't
       reading or writing. */
    if ((*mode & BAREAD || *mode & BAWRITE) && (*nactual != *no))
        return BA_EFEWDATA;
    else 
        return BA_NOERROR;
}

/**
 * Do bacio operation.
 *
 * @param mode integer specifying operations to be performed see the
 * clib.inc file for the values. Mode is obtained by adding together
 * the values corresponding to the operations The best method is to
 * include the clib.inc file and refer to the names for the operations
 * rather than rely on hard-coded values.
 * @param start byte number to start your operation from. 0 is the
 * first byte in the file, not 1.
 * @param newpos position in the file after a read or write has been
 * performed. You'll need this if you're doing 'seeking' read/write.
 * @param size is the size of the objects you are trying to
 * read. Types are CHARACTER, INTEGER, REAL, COMPLEX.
 * @param no is the number of things to read or write (characters,
 * integers, whatever).
 * @param nactual is the number of things actually read or
 * written. Check that you got what you wanted.
 * @param fdes is an integer 'file descriptor'. This is not a Fortran
 * Unit Number You can use it, however, to refer to files you've
 * previously opened.
 * @param fname is the name of the file. This only needs to be defined
 * when you are opening a file. It must be (on the Fortran side)
 * declared as CHARACTER*N, where N is a length greater than or equal
 * to the length of the file name. CHARACTER*1 fname[80] (for example)
 * will fail.
 * @param datary is the name of the entity (variable, vector, array)
 * that you want to write data out from or read it in to. The fact
 * that C is declaring it to be a char * does not affect your fortran.
 * @param namelen - Length of the name.
 * @param datanamelen - Length of data. (Not used).
 *
 * This function is called from the Fortran code in baciof.f90.
 *
 * @return ::BA_NOERROR No error.
 * @return ::BA_EROANDWO Tried to open read only and write only.
 * @return ::BA_ERANDW Tried to read and write in the same call.
 * @return ::BA_EINTNAME Internal failure in name processing.
 * @return ::BA_EFILEOPEN Failure in opening file.
 * @return ::BA_ERONWO Tried to read on a write-only file.
 * @return ::BA_ERNOSTART Failed in read to find the 'start' location.
 * @return ::BA_EWANDRO Tried to write to a read only file.
 * @return ::BA_EWNOSTART Failed in write to find the 'start' location.
 * @return ::BA_ECLOSE Error in close.
 * @return ::BA_EFEWDATA Read or wrote fewer data than requested.
 * @return ::BA_EDATANULL Data pointer is NULL.
 *
 * @author Robert Grumbine, Ed Hartnett
 */
int
bacio_(int *mode, int *start, int *newpos, int *size, int *no,
       int *nactual, int *fdes, const char *fname, char *datary,
       int namelen, int datanamelen)
{
    long int lstart;
    long int lnewpos;
    long int lno;
    long int lnactual;
    int ret;

    /* Copy these parameters to int*8. */
    lstart = *start;
    lnewpos = *newpos;
    lno = *no;

    /* Call the version of this function with long int parameters. */
    ret = baciol_(mode, &lstart, &lnewpos, size, &lno, &lnactual, fdes,
                  fname, datary, namelen, datanamelen);

    /* Copy the number of bytes read/written to the 4-byte int. */
    *nactual = lnactual;

    return ret;
}
