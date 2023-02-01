@mainpage

# bacio

This library performs binary I/O for the NCEP models, processing
formatted and unformatted byte-addressable data records, and helping
transform little endian files into big endian files.

## Documentation for Previous Versions of NCEPLIBS-g2

* [NCEPLIBS-bacio Version 2.5.0](ver-2.5.0/index.html)

## Fortran Library

The NCEPLIBS-bacio has Fortran functions to open, read or write, and
close either formatted or unformatted Fortran files.

### Opening or Creating a Data File

Open or create the file with one of the baopen() family of functions.

* baopen() - Open a new or existing file for read/write.
* baopenr() - Open an existing file for read-only.
* baopenw() - Open a new or existing file for write only.
* baopenwt() - Open an existing file for write only, truncating
  current contents of the file.
* baopenwt() - Open an existing file for write only, appending to the
  current contents of the file.

### Reading or Writing Unformatted Records

To read from an unformatted file, use:
* baread() - Read from an unformatted file.
* bareadl() - Read from an unformatted file, with integer*8 function
  parameters.

To write from an unformatted file, use:
* bawrite() - Write from an unformatted file.
* bawritel() - Write from an unformatted file, with integer*8 function
  parameters.

### Reading or Writing Formatted Records

To read from an formatted file, use:
* bafrread() - Read from an unformatted file.
* bafrreadl() - Read from an unformatted file, with integer*8 function
  parameters.

To write from an formatted file, use:
* bafrwrite() - Write from an unformatted file.
* bafrwritel() - Write from an unformatted file, with integer*8 function
  parameters.

### Closing the File

Close the data file with the baclose() function. All data files must
be closed after use, to flush buffers and free resources.

## C Backend

The Fortran functions all call the backend C function bacio_(), which
does the heavy lifting for the NCEPLIBS-bacio library. Users should
use the Fortran API for NCEPLIBS-bacio.


