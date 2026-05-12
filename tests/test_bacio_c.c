/* This is a test for the NCEPLIBS-bacio project.
 *
 * This is a C test for the C code in bacio.c.
 *
 * Ed Hartnett 10/6/21
 * Coverage improvements added
 */

#include <stdio.h>
#include <clib.h>
#include <string.h>
#include <stdlib.h>

/* Prototype for the function being tested. */
int baciol(int mode, long int start, int size, long int no,
           long int *nactual, int *fdes, const char *fname, void *datary);

#define ERR 99

/* Function prototypes for test helpers */
int test_write_seek_fails(void);
int test_zero_byte_read(void);
int test_null_char_filename(void);
int test_buffered_reading_edge_cases(void);

/* Test BA_EWNOSTART - Line 142: Write seek fails */
int test_write_seek_fails(void)
{
    printf("Testing BA_EWNOSTART error (write seek fails)...");
    int mode;
    long int start = 999999999; /* Very large seek position */
    long int no = 4, nactual;
    int size = 4, fdes;
    const char fname[] = "test_ewnostart.bin";
    char datary[] = "test";
    int ierr;

    /* Create file first */
    mode = BAOPEN_WONLY;
    ierr = baciol(mode, 0, size, no, &nactual, &fdes, fname, datary);
    if (ierr != 0)
    {
        printf("Failed to create file\n");
        return ERR;
    }

    /* Try to write with impossible seek - should return BA_EWNOSTART (248) */
    mode = BAWRITE;
    ierr = baciol(mode, start, size, no, &nactual, &fdes, fname, datary);
    if (ierr != 248)
    {
        printf("Expected BA_EWNOSTART (248), got %d\n", ierr);
        
        /* Close the file to clean up */
        mode = BACLOSE;
        baciol(mode, 0, size, no, &nactual, &fdes, fname, datary);
        
        return ERR;
    }

    /* Additional verification */
    if (nactual != 0)
    {
        printf("Expected nactual to be 0, got %ld\n", nactual);
        
        /* Close the file to clean up */
        mode = BACLOSE;
        baciol(mode, 0, size, no, &nactual, &fdes, fname, datary);
        
        return ERR;
    }

    /* Close the file */
    mode = BACLOSE;
    ierr = baciol(mode, 0, size, no, &nactual, &fdes, fname, datary);
    if (ierr != 0)
    {
        printf("Failed to close file\n");
        return ERR;
    }

    printf("ok!\n");
    return 0;
}

/* Test coverage for line 420-421 in baciof.F90: KA = 0, RETURN */
int test_zero_byte_read(void)
{
    printf("Testing zero byte read scenario...");
    int mode;
    long int start = 0;
    long int no = 0, nactual;  // Zero bytes to read
    int size = 4, fdes;
    const char fname[] = "test_zero_read.bin";
    char datary[1] = {0};
    int ierr;

    /* Create file */
    mode = BAOPEN_WONLY;
    if ((ierr = baciol(mode, start, size, 4, &nactual, &fdes, fname, datary)))
    {
        printf("Failed to create file\n");
        return ERR;
    }

    /* Write some initial data */
    mode = BAWRITE;
    if ((ierr = baciol(mode, start, size, 4, &nactual, &fdes, fname, datary)))
    {
        printf("Failed to write data\n");
        return ERR;
    }

    /* Close file */
    mode = BACLOSE;
    if ((ierr = baciol(mode, start, size, 4, &nactual, &fdes, fname, datary)))
    {
        printf("Failed to close file\n");
        return ERR;
    }

    /* Reopen for reading */
    mode = BAOPEN_RONLY;
    if ((ierr = baciol(mode, start, size, no, &nactual, &fdes, fname, datary)) != 0)
    {
        printf("Expected successful zero-byte read, got %d\n", ierr);
        return ERR;
    }

    /* Verify nactual is zero */
    if (nactual != 0)
    {
        printf("Expected nactual to be zero, got %ld\n", nactual);
        return ERR;
    }

    /* Close file */
    mode = BACLOSE;
    if ((ierr = baciol(mode, start, size, 4, &nactual, &fdes, fname, datary)))
    {
        printf("Failed to close file\n");
        return ERR;
    }

    printf("ok!\n");
    return 0;
}

/* Test coverage for line 441 in baciof.F90: CHAR(0) parameter */
int test_null_char_filename(void)
{
    printf("Testing CHAR(0) file name scenario...");
    int mode;
    long int start = 0;
    long int no = 4, nactual;
    int size = 4, fdes;
    const char fname[] = "\0";  // Null character filename
    char datary[] = "test";
    int ierr;

    /* Scenario 1: Attempt to open with null character filename */
    mode = BAOPEN_WONLY;
    ierr = baciol(mode, start, size, no, &nactual, &fdes, fname, datary);
    if (ierr == 0)  // Unexpected successful open
    {
        printf("Unexpected successful open with null character filename\n");
        return ERR;
    }

    /* Scenario 2: Attempt to write with null character filename */
    mode = BAWRITE;
    ierr = baciol(mode, start, size, no, &nactual, &fdes, fname, datary);
    if (ierr == 0)  // Unexpected successful write
    {
        printf("Unexpected successful write with null character filename\n");
        return ERR;
    }

    /* Scenario 3: Attempt to read with null character filename */
    mode = BAOPEN_RONLY;
    ierr = baciol(mode, start, size, no, &nactual, &fdes, fname, datary);
    if (ierr == 0)  // Unexpected successful read
    {
        printf("Unexpected successful read with null character filename\n");
        return ERR;
    }

    printf("ok!\n");
    return 0;
}

/* Test coverage for buffered reading edge cases */
int test_buffered_reading_edge_cases(void)
{
    printf("Testing buffered reading edge cases...");
    int mode;
    long int start = 0;
    long int no = 4096 * 5;  // Large buffer spanning multiple blocks
    int size = 1, fdes;
    const char fname[] = "test_large_buffered.bin";
    char *large_datary = NULL;
    char *read_datary = NULL;
    long int nactual;
    int ierr;

    /* Allocate memory for large data */
    large_datary = malloc(no);
    if (!large_datary)
    {
        printf("Memory allocation failed for large_datary\n");
        return ERR;
    }

    read_datary = malloc(no);
    if (!read_datary)
    {
        printf("Memory allocation failed for read_datary\n");
        free(large_datary);
        return ERR;
    }

    /* Prepare large data with predictable pattern */
    for (long int i = 0; i < no; i++)
        large_datary[i] = (char)(i % 256);

    /* Create file with large data */
    mode = BAOPEN_WONLY;
    ierr = baciol(mode, start, size, no, &nactual, &fdes, fname, large_datary);
    if (ierr != 0)
    {
        printf("Failed to create file for large data\n");
        free(large_datary);
        free(read_datary);
        return ERR;
    }

    /* Close file */
    mode = BACLOSE;
    ierr = baciol(mode, start, size, no, &nactual, &fdes, fname, large_datary);
    if (ierr != 0)
    {
        printf("Failed to close file after writing\n");
        free(large_datary);
        free(read_datary);
        return ERR;
    }

    /* Reopen for reading */
    mode = BAOPEN_RONLY;
    ierr = baciol(mode, start, size, no, &nactual, &fdes, fname, read_datary);
    if (ierr != 0)
    {
        printf("Failed to reopen file for reading\n");
        free(large_datary);
        free(read_datary);
        return ERR;
    }

    /* Verify number of bytes read */
    if (nactual != no)
    {
        printf("Unexpected number of bytes read. Expected %ld, got %ld\n",
               no, nactual);
        free(large_datary);
        free(read_datary);
        return ERR;
    }

    /* Verify data integrity */
    for (long int i = 0; i < no; i++)
    {
        if (large_datary[i] != read_datary[i])
        {
            printf("Data mismatch at position %ld\n", i);
            free(large_datary);
            free(read_datary);
            return ERR;
        }
    }

    /* Close file */
    mode = BACLOSE;
    ierr = baciol(mode, start, size, no, &nactual, &fdes, fname, read_datary);
    if (ierr != 0)
    {
        printf("Failed to close file after reading\n");
        free(large_datary);
        free(read_datary);
        return ERR;
    }

    /* Clean up */
    free(large_datary);
    free(read_datary);

    printf("ok!\n");
    return 0;
}

/* Main test function */
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
        long int no = 4, nactual;
        int size = 4, fdes;
        const char fname[] = "test_baciol_c.bin";
        const char bad_fname[] = "file_of_pure_evil.bin";
        char datary[] = "test";
        char datary_in[4];
        int ierr;

        /* This won't work - bad mode. */
        mode = BAOPEN_WONLY | BAOPEN_RONLY;
        if ((ierr = baciol(mode, start, size, no, &nactual,
                           &fdes, fname, datary)) != 255)
            return ERR;

           /* This won't work - bad mode. */
        mode = BAREAD | BAWRITE;
        if ((ierr = baciol(mode, start, size, no, &nactual,
                           &fdes, fname, datary)) != 254)
            return ERR;
        
        /* Create the file. */
        mode = BAOPEN_WONLY;
        if ((ierr = baciol(mode, start, size, no, &nactual,
                           &fdes, fname, datary)))
            return ierr;

        /* Try to write some data - won't work, null data pointer. */
        mode = BAWRITE;
        if ((ierr = baciol(mode, start, size, no, &nactual,
                            &fdes, fname, NULL)) != 102)
            return ERR;

        /* Write some data. */
        mode = BAWRITE;
        if ((ierr = baciol(mode, start, size, no, &nactual,
                           &fdes, fname, datary)))
            return ierr;
        if (nactual != no) return ERR;

        /* Close the file. */
        mode = BACLOSE;
        if ((ierr = baciol(mode, start, size, no, &nactual,
                           &fdes, fname, datary)))
            return ierr;

        /* Try to close the file again - won't work. */
        mode = BACLOSE;
        if ((ierr = baciol(mode, start, size, no, &nactual,
                           &fdes, fname, datary)) != 247)
            return ierr;

        /* Try to reopen the file with a bad name - won't work. */
        mode = BAOPEN_RONLY;
        if ((ierr = baciol(mode, start, size, no, &nactual,
                           &fdes, bad_fname, datary)) != 252)
            return ierr;

        /* Reopen the file. */
        mode = BAOPEN_RONLY;
        if ((ierr = baciol(mode, start, size, no, &nactual,
                           &fdes, fname, datary)))
            return ierr;

        /* This won't work - NULL data array. */
        mode = BAREAD;
        if ((ierr = baciol(mode, start, size, no, &nactual,
                           &fdes, fname, NULL)) != 102)
            return ERR;
        
        /* This won't work - bad fdes. */
        mode = BAREAD;
        if ((ierr = baciol(mode, start, size, no, &nactual,
                           &bad_fdes, fname, datary_in)) != 250)
            return ERR;

        /* This won't work - another bad fdes. */
        mode = BAREAD;
        bad_fdes = -10;
        if ((ierr = baciol(mode, start, size, no, &nactual,
                           &bad_fdes, fname, datary_in)) != 252)
            return ERR;

        /* This won't work - seek too large. */
        mode = BAREAD;
        if ((ierr = baciol(mode, bad_start, size, no, &nactual,
                           &fdes, fname, datary_in)) != 246)
            return ERR;

        /* Read the data we just wrote. */
        mode = BAREAD;
        if ((ierr = baciol(mode, start, size, no, &nactual,
                           &fdes, fname, datary_in)))
            return ierr;
        if (nactual != no) return ERR;
        for (int i = 0; i < 4; i++)
            if (datary[i] != datary_in[i]) return ERR;

        /* Close the file. */
        mode = BACLOSE;
        if ((ierr = baciol(mode, start, size, no, &nactual,
                           &fdes, fname, datary)))
            return ierr;

    }
    printf("ok!\n");
    printf("Testing some other simple baciol() calls...");
    {
        int mode;
        long int start = 0;
        long int no = 4, nactual;
        int size = 4, fdes;
        const char fname[] = "test_baciolc.bin";
        char datary[] = "test";
        char datary_in[8];
        int ierr;

        /* Create the file. */
        mode = BAOPEN_WONLY_TRUNC;
        if ((ierr = baciol(mode, start, size, no, &nactual,
                           &fdes, fname, datary)))
            return ierr;

        /* Write some data. */
        mode = BAWRITE | NOSEEK;
        if ((ierr = baciol(mode, start, size, no, &nactual,
                           &fdes, fname, datary)))
            return ierr;
        if (nactual != no) return ERR;

        /* Close the file. It now contains "test". */
        mode = BACLOSE;
        if ((ierr = baciol(mode, start, size, no, &nactual,
                           &fdes, fname, datary)))
            return ierr;

        /* Reopen the file. */
        mode = BAOPEN_RW;
        if ((ierr = baciol(mode, start, size, no, &nactual,
                           &fdes, fname, datary)))
            return ierr;

        /* Read the data we just wrote. */
        mode = BAREAD;
        if ((ierr = baciol(mode, start, size, no, &nactual,
                           &fdes, fname, datary_in)))
            return ierr;
        if (nactual != no) return ERR;
        for (int i = 0; i < 4; i++)
            if (datary[i] != datary_in[i]) return ERR;

        /* Close the file. */
        mode = BACLOSE;
        if ((ierr = baciol(mode, start, size, no, &nactual,
                           &fdes, fname, datary)))
            return ierr;

        /* Reopen the file to append more data. */
        mode = BAOPEN_WONLY_APPEND;
        if ((ierr = baciol(mode, start, size, no, &nactual,
                           &fdes, fname, datary)))
            return ierr;

        /* Write some data. */
        mode = BAWRITE;
        start = 4;
        if ((ierr = baciol(mode, start, size, no, &nactual,
                           &fdes, fname, datary)))
            return ierr;
        if (nactual != no) return ERR;
        start = 0;

        /* Close the file. */
        mode = BACLOSE;
        if ((ierr = baciol(mode, start, size, no, &nactual,
                           &fdes, fname, datary)))
            return ierr;

        /* Reopen the file. */
        mode = BAOPEN_RONLY;
        if ((ierr = baciol(mode, start, size, no, &nactual,
                           &fdes, fname, datary)))
            return ierr;

        /* Read the data we just wrote. It now contains "testtest". */
        mode = BAREAD;
        size = 8;
        no = 8;
        if ((ierr = baciol(mode, start, size, no, &nactual,
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
        if ((ierr = baciol(mode, start, size, no, &nactual,
                           &fdes, fname, datary)))
            return ierr;

    }
    printf("ok!\n");

    /* Test BA_ERONWO - Line 115: Try to read on write-only file */
    printf("Testing BA_ERONWO error...");
    {
        int mode;
        long int start = 0;
        long int no = 4, nactual;
        int size = 4, fdes;
        const char fname[] = "test_eronwo.bin";
        char datary[] = "test";
        char datary_in[4];
        int ierr;

        /* Open file write-only */
        mode = BAOPEN_WONLY;
        if ((ierr = baciol(mode, start, size, no, &nactual, &fdes, fname, datary)))
            return ERR;

        /* Try to read from write-only file - should return BA_ERONWO (250) */
        mode = BAREAD | BAOPEN_WONLY;
        if ((ierr = baciol(mode, start, size, no, &nactual, &fdes, fname, datary_in)) != 250)
        {
            printf("Expected BA_ERONWO (250), got %d\n", ierr);
            return ERR;
        }

        /* Close the file */
        mode = BACLOSE;
        baciol(mode, start, size, no, &nactual, &fdes, fname, datary);
    }
    printf("ok!\n");

    /* Test BA_EWANDRO - Line 135: Try to write to read-only file */
    printf("Testing BA_EWANDRO error...");
    {
        int mode;
        long int start = 0;
        long int no = 4, nactual;
        int size = 4, fdes;
        const char fname[] = "test_ewandro.bin";
        char datary[] = "test";
        int ierr;

        /* Create file first */
        mode = BAOPEN_WONLY;
        if ((ierr = baciol(mode, start, size, no, &nactual, &fdes, fname, datary)))
            return ERR;
        mode = BAWRITE;
        baciol(mode, start, size, no, &nactual, &fdes, fname, datary);
        mode = BACLOSE;
        baciol(mode, start, size, no, &nactual, &fdes, fname, datary);

        /* Open file read-only */
        mode = BAOPEN_RONLY;
        if ((ierr = baciol(mode, start, size, no, &nactual, &fdes, fname, datary)))
            return ERR;

        /* Try to write to read-only file - should return BA_EWANDRO (249) */
        mode = BAWRITE | BAOPEN_RONLY;
        if ((ierr = baciol(mode, start, size, no, &nactual, &fdes, fname, datary)) != 249)
        {
            printf("Expected BA_EWANDRO (249), got %d\n", ierr);
            return ERR;
        }

        /* Close the file */
        mode = BACLOSE;
        baciol(mode, start, size, no, &nactual, &fdes, fname, datary);
    }
    printf("ok!\n");

    /* NEW: Insert additional test cases here */
    printf("Running additional test cases...\n");

    /* Test zero byte read */
    if (test_zero_byte_read() != 0)
    {
        printf("Zero byte read test failed\n");
        return ERR;
    }

    /* Test null character filename */
    if (test_null_char_filename() != 0)
    {
        printf("Null character filename test failed\n");
        return ERR;
    }

    /* Test write seek fails */
    if (test_write_seek_fails() != 0)
    {
        printf("Write seek fails test failed\n");
        return ERR;
    }

    /* Test buffered reading edge cases */
    if (test_buffered_reading_edge_cases() != 0)
    {
        printf("Buffered reading edge cases test failed\n");
        return ERR;
    }

    printf("SUCCESS!\n");
    return 0;
}
