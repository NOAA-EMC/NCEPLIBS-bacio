#include <sys/types.h>
#include <errno.h>
#include <string.h>
#include <stdio.h>

// Mocking read to simulate a partial read (hits the 'while' loop in bacio.c)
ssize_t __real_read(int fd, void *buf, size_t count);
ssize_t __wrap_read(int fd, void *buf, size_t count) {
    if (count > 10) {
        return __real_read(fd, buf, count / 2); // Force bacio to loop
    }
    return __real_read(fd, buf, count);
}

// Mocking write to simulate an Interrupted system call (hits the EINTR branch)
ssize_t __real_write(int fd, const void *buf, size_t count);
static int interrupt_triggered = 0;
ssize_t __wrap_write(int fd, const void *buf, size_t count) {
    if (!interrupt_triggered && count > 0) {
        interrupt_triggered = 1;
        errno = EINTR; 
        return -1;
    }
    return __real_write(fd, buf, count);
}

// Mocking open to simulate permission/existence failures
int __real_open(const char *pathname, int flags, mode_t mode);
int __wrap_open(const char *pathname, int flags, mode_t mode) {
    if (strstr(pathname, "forbidden")) {
        errno = EACCES;
        return -1;
    }
    return __real_open(pathname, flags, mode);
}
