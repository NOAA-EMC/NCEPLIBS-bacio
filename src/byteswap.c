/** @file
 *
 * This file contains various implementations of fast byteswapping
 * routines. The main entry point, fast_byteswap(), is the only one
 * you should need, and it should be modified to use whatever method
 * is fastest on your architecture.
 *
 * In all cases, the routines return 1 on success and 0 on failure.
 * They only fail if your data is non-aligned. All routines require
 * that arrays of N-bit data be N-bit aligned. If they are not, an
 * error will be sent to stderr and the routine will return non-zero.
 * To silence the error message, call fast_byteswap_errors(0).
 *
 * @author Dexin Zhang, Jun Wang
*/

// no byteswap.h on Apple
#ifdef APPLE
#include <libkern/OSByteOrder.h>
#define bswap_16(x) OSSwapInt16(x)
#define bswap_32(x) OSSwapInt32(x)
#define bswap_64(x) OSSwapInt64(x)
#else
#include <byteswap.h>
#endif
#include <stdint.h>
#include <stdlib.h>
#include <stdio.h>

#define BLOCK_COUNT_64 (512*1024) /**< Block Count 64. */
#define BLOCK_COUNT_32 (1024*1024) /**< Block Count 32. */
#define BLOCK_COUNT_16 (2048*1024) /**< Block Count 16. */
#define LINUX /**< Define LINUX. */

static int send_errors = 1; /**< if non-zero, warn about non-aligned pointers */
static int fast_count_calls = 0; /**< Fast count calls. */

/**
 * Set a flag to turn warnings off for non-aligned pointers.
 *
 * @param flag Set to 0 to turn off warnings, non-zero to turn them on
 * (the default).
 */
void
fast_byteswap_errors(int flag)
{
  send_errors=flag;
}

/**
 * Simple single-value loops.
 *
 * @param data data
 * @param len Length
 *
 * @return 0 for error, 1 otherwise.
 */
static int
simple_swap_64(void *data,size_t len)
{
  size_t i;
  uint64_t *udata;
  if( ((size_t)data)&0x5 != 0 ) {
    if (send_errors)
      fprintf(stderr,"ERROR: pointer to 64-bit integer is not 64-bit aligned (pointer is 0x%llx)\n",(long long)data);
    return 0;
  }
  udata=data;
  for(i=0;i<len;i++)
    udata[i]=
      ( (udata[i]>>56)&0xff ) |
      ( (udata[i]>>40)&0xff00 ) |
      ( (udata[i]>>24)&0xff0000 ) |
      ( (udata[i]>>8) &0xff000000 ) |
      ( (udata[i]<<8) &0xff00000000 ) |
      ( (udata[i]<<24)&0xff0000000000 ) |
      ( (udata[i]<<40)&0xff000000000000 ) |
      ( (udata[i]<<56)&0xff00000000000000 );
  return 1;
}

/**
 * Simple single-value loops.
 *
 * @param data data
 * @param len Length
 *
 * @return 0 for error, 1 otherwise.
 */
static int
simple_swap_32(void *data,size_t len)
{
  size_t i;
  uint32_t *udata;
  if( ((size_t)data)&0x3 != 0 ) {
    if (send_errors)
      fprintf(stderr,"ERROR: pointer to 32-bit integer is not 32-bit aligned (pointer is 0x%llx)\n",(long long)data);
    return 0;
  }
  udata=data;
  for(i=0;i<len;i++)
    udata[i]=
      ( (udata[i]>>24)&0xff ) |
      ( (udata[i]>>8)&0xff00 ) |
      ( (udata[i]<<8)&0xff0000 ) |
      ( (udata[i]<<24)&0xff000000 );
  return 1;
}

/**
 * Simple single-value loops.
 *
 * @param data data
 * @param len Length
 *
 * @return 0 for error, 1 otherwise.
 */
static int
simple_swap_16(void *data,size_t len)
{
  size_t i;
  uint16_t *udata;
  if( ((size_t)data)&0x1 != 0 ) {
    if (send_errors)
      fprintf(stderr,"ERROR: pointer to 16-bit integer is not 16-bit aligned (pointer is 0x%llx)\n",(long long)data);
    return 0;
  }
  udata=data;
  for(i=0;i<len;i++)
    udata[i]=
      ( (udata[i]>>8)&0xff ) |
      ( (udata[i]<<8)&0xff00 );
  return 1;
}

/**
 * Use the GNU macros, which are specialized byteswap ASM
 * instructions.
 *
 * @param data data
 * @param len Length
 *
 * @return 0 for error, 1 otherwise.
 */
static int
macro_swap_64(void *data,size_t len)
{
  size_t i;
  uint64_t *udata;
  if( ((size_t)data)&0x5 != 0 ) {
    if (send_errors)
      fprintf(stderr,"ERROR: pointer to 64-bit integer is not 64-bit aligned (pointer is 0x%llx)\n",(long long)data);
    return 0;
  }
  udata=data;
  for(i=0;i<len;i++)
    udata[i]=bswap_64(udata[i]);
  return 1;
}

/**
 * Use the GNU macros, which are specialized byteswap ASM
 * instructions.
 *
 * @param data data
 * @param len Length
 *
 * @return 0 for error, 1 otherwise.
 */
static int
macro_swap_32(void *data,size_t len)
{
  size_t i;
  uint32_t *udata;
  if( ((size_t)data)&0x3 != 0 ) {
    if (send_errors)
      fprintf(stderr,"ERROR: pointer to 32-bit integer is not 32-bit aligned (pointer is 0x%llx)\n",(long long)data);
    return 0;
  }
  udata=data;
  for(i=0;i<len;i++)
    udata[i]=bswap_32(udata[i]);
  return 1;
}

/**
 * Use the GNU macros, which are specialized byteswap ASM
 * instructions.
 *
 * @param data data
 * @param len Length
 *
 * @return 0 for error, 1 otherwise.
 */
static int
macro_swap_16(void *data,size_t len)
{
  size_t i;
  uint16_t *udata;
  if( ((size_t)data)&0x1 != 0 ) {
    if (send_errors)
      fprintf(stderr,"ERROR: pointer to 16-bit integer is not 16-bit aligned (pointer is 0x%llx)\n",(long long)data);
    return 0;
  }
  udata=data;
  for(i=0;i<len;i++)
    udata[i]=bswap_16(udata[i]);
  return 1;
}

/**
 * Use the GNU macros and do 1MB blocks at a time. Control the block
 * size through the BLOCK_COUNT_* macros (top of file).
 *
 * @param data data
 * @param len Length
 *
 * @return 0 for error, 1 otherwise.
 */
static int
block_macro_swap_32(void *data,size_t len)
{
  size_t i,stop,j;
  uint32_t *udata;
  if( ((size_t)data)&0x3 != 0 ) {
    if (send_errors)
      fprintf(stderr,"ERROR: pointer to 32-bit integer is not 32-bit aligned (pointer is 0x%llx)\n",(long long)data);
    return 0;
  }
  /* Swap full blocks first: */
  udata=data;
  stop=len/BLOCK_COUNT_32*BLOCK_COUNT_32;
  for(i=0;i<stop;i+=BLOCK_COUNT_32)
    for(j=0;j<BLOCK_COUNT_32;j++)
      udata[i+j]=bswap_32(udata[i+j]);
  /* Swap remainder */
  for(i=stop;i<len;i++)
    udata[i]=bswap_32(udata[i]);
  return 1;
}

/**
 * Use the GNU macros and do 1MB blocks at a time. Control the block
 * size through the BLOCK_COUNT_* macros (top of file).
 *
 * @param data data
 * @param len Length
 *
 * @return 0 for error, 1 otherwise.
 */
static int
block_macro_swap_16(void *data,size_t len)
{
  size_t i,stop,j;
  uint16_t *udata;
  if( ((size_t)data)&0x1 != 0 ) {
    if (send_errors)
      fprintf(stderr,"ERROR: pointer to 16-bit integer is not 16-bit aligned (pointer is 0x%llx)\n",(long long)data);
    return 0;
  }
  /* Swap full blocks first: */
  udata=data;
  stop=len/BLOCK_COUNT_16*BLOCK_COUNT_16;
  for(i=0;i<stop;i+=BLOCK_COUNT_16)
    for(j=0;j<BLOCK_COUNT_16;j++)
      udata[i+j]=bswap_16(udata[i+j]);
  /* Swap remainder */
  for(i=stop;i<len;i++)
    udata[i]=bswap_16(udata[i]);
  return 1;
}

/**
 * Use the GNU macros and do 1MB blocks at a time. Control the block
 * size through the BLOCK_COUNT_* macros (top of file).
 *
 * @param data data
 * @param len Length
 *
 * @return 0 for error, 1 otherwise.
 */
static int
block_macro_swap_64(void *data,size_t len)
{
  uint64_t *udata;
  size_t i,stop,j;
  if( ((size_t)data)&0x5 != 0 ) {
    if (send_errors)
      fprintf(stderr,"ERROR: pointer to 64-bit integer is not 64-bit aligned (pointer is 0x%llx)\n",(long long)data);
    return 0;
  }
  /* Swap full blocks first: */
  udata=data;
  stop=len/BLOCK_COUNT_64*BLOCK_COUNT_64;
  for(i=0;i<stop;i+=BLOCK_COUNT_64)
    for(j=0;j<BLOCK_COUNT_64;j++)
      udata[i+j]=bswap_64(udata[i+j]);
  /* Swap remainder */
  for(i=stop;i<len;i++)
    udata[i]=bswap_64(udata[i]);
  return 1;
}

/**
 * Fast byteswap.
 *
 * @param data data
 * @param bytes Number of bytes
 * @param count Count.
 *
 * @return 0 for error, 1 otherwise.
 */
int
fast_byteswap(void *data,int bytes,size_t count)
{
  switch(bytes) {
  case 1: return 1;
  case 2: return simple_swap_16(data,count);
  case 4: return simple_swap_32(data,count);
  case 8: return macro_swap_64(data,count);
  default: return 0;
  }
}

/* Include the C library file for definition/control */
/* Things that might be changed for new systems are there. */
/* This source file should not (need to) be edited, merely recompiled */
#include "clib.h"
#include "stdio.h"
#include "fast-byteswap.h"

/**
 * Byteswap.
 *
 * @param data Data
 * @param nbyte Number of bytes.
 * @param nnum NNUM
 *
 */
void
byteswap_(char *data, int *nbyte, int *nnum)
{
    int  i, j;
    char swap[256];
    int  nb=*nbyte;
    int  nn=*nnum;
    size_t count=*nnum;
    if( fast_count_calls == 0 ) {
        fprintf (stderr, " FAST_BYTESWAP ALGORITHM HAS BEEN USED AND DATA ALIGNMENT IS CORRECT FOR  %9d  )\n",nb );
        fast_count_calls= 1 ;
    }

    if(fast_byteswap(data,nb,count)) {
        /**********     fprintf (stderr," FAST_BYTESWAP WORKED FOR  %9d %9d )\n",nb, count); *******/
        /* it succeeded: data is now byteswapped */
    } else {
        fprintf(stderr,"ERROR NOT ALIGNED SLOW CODE USED (nb and count %9d %9lu )\n",nb, count);
        /* It failed.  No data was byteswapped because it is not aligned */
        for (j=0; j<nn; j++) {
            for (i=0; i<nb; i++)
                swap[i] = data[j*nb+i];
            for (i=0; i<nb; i++)
                data[j*nb+i] = swap[nb-i-1];
        }
    }
}
