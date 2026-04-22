#include <sys/types.h>
#include <errno.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>

// 1. Mock system calls for bacio.c coverage
ssize_t __real_read(int fd, void *buf, size_t count);
ssize_t __wrap_read(int fd, void *buf, size_t count) {
    if (count > 10 && count < 100) return __real_read(fd, buf, count / 2); // Force while loop
    return __real_read(fd, buf, count);
}

int __real_close(int fd);
int __wrap_close(int fd) {
    if (fd == 999) return -1; // Force BA_ECLOSE error
    return __real_close(fd);
}

// 2. Mock blank common block for chk_endianc.F90 coverage
char __blank_common_block[4]; 
void force_endian_mock(const char *pattern) {
    memcpy(__blank_common_block, pattern, 4);
}

// 3. Helper to provide misaligned pointers for byteswap.c coverage
void* get_misaligned_ptr(void* ptr, int offset) {
    return (char*)ptr + offset;
}
