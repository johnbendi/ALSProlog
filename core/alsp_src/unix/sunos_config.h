/* SunOS fails to define EXIT_FAILURE and EXIT_SUCCESS */

/* 
 * config.d.in is a template file used by configure to produce config.d.
 * config.d is then transformed (by configure) into the header file config.h.
 */

/* SunOS 4.1.* does not have the standard regcomp() library, so use
   re_comp().
*/
#define USE_RE_COMP 1
#define SUNOS_AOUT 1
#define MISSING_EXTERN_CRYPT
#define MISSING_EXTERN_STRTOUL
#define MISSING_STRTOUL
#define MISSING_EXTERN_REALPATH
#define MISSING_EXTERN_GETIMEOFDAY

#define MinorOSStr	"sunos4.1.3"
#define HAVE_MACHINE_PARAM_H	1
#define HAVE_MEMORY_H	1
#define HAVE_SGTTY_H	1
#define HAVE_DLFCN_H	1
#define HAVE_RESTARTABLE_SYSCALLS	1
#define HAVE_LIBDL	1
#define HAVE_LIBNSL	1
#define HAVE_DEV_ZERO	1
#define HAVE_BSD_SETPGRP	1
#define HAVE_AINT	1
#define HAVE_BCOPY	1
#define HAVE_DLOPEN	1
#define HAVE_EXP10	1
#define HAVE_GAMMA	1
#define HAVE_GETPAGESIZE	1
#define HAVE_GETWD	1
#define HAVE_POLL	1
#define HAVE_RE_COMP	1
#define HAVE_RINT	1
#define HAVE_SIGACTION	1
#define HAVE_SIGSTACK	1
#define HAVE_SIGVEC	1
#define HAVE_SRANDOM	1
#define HAVE_WAIT3	1
#define MISSING_EXTERN__FILBUF	1
#define MISSING_EXTERN__FLSBUF	1
#define MISSING_EXTERN_ACCEPT	1
#define MISSING_EXTERN_BCOPY	1
#define MISSING_EXTERN_BIND	1
#define MISSING_EXTERN_BRK	1
#define MISSING_EXTERN_BZERO	1
#define MISSING_EXTERN_CONNECT	1
#define MISSING_EXTERN_FCLOSE	1
#define MISSING_EXTERN_FFLUSH	1
#define MISSING_EXTERN_FPRINTF	1
#define MISSING_EXTERN_SSCANF	1
#define MISSING_EXTERN_FPUTC	1
#define MISSING_EXTERN_FGETC	1
#define MISSING_EXTERN_FREAD	1
#define MISSING_EXTERN_FSEEK	1
#define MISSING_EXTERN_FWRITE	1
#define MISSING_EXTERN_GETHOSTNAME	1
#define MISSING_EXTERN_GETPAGESIZE	1
#define MISSING_EXTERN_GETSOCKNAME	1
#define MISSING_EXTERN_GETWD	1
#define MISSING_EXTERN_LDOPEN	1
#define MISSING_EXTERN_LISTEN	1
#define MISSING_EXTERN_MEMMOVE	1
#define MISSING_EXTERN_MEMSET	1
#define MISSING_EXTERN_MPROTECT	1
#define MISSING_EXTERN_PERROR	1
#define MISSING_EXTERN_PRINTF	1
#define MISSING_EXTERN_READLINK	1
#define MISSING_EXTERN_RECVFROM	1
#define MISSING_EXTERN_RE_COMP	1
#define MISSING_EXTERN_RE_EXEC	1
#define MISSING_EXTERN_REWIND	1
#define MISSING_EXTERN_REXEC	1
#define MISSING_EXTERN_SBRK	1
#define MISSING_EXTERN_SELECT	1
#define MISSING_EXTERN_SENDTO	1
#define MISSING_EXTERN_SETITIMER	1
#define MISSING_EXTERN_SETPGRP	1
#define MISSING_EXTERN_SETVBUF	1
#define MISSING_EXTERN_SHUTDOWN	1
#define MISSING_EXTERN_SIGSTACK	1
#define MISSING_EXTERN_SIGVEC	1
#define MISSING_EXTERN_SOCKET	1
#define MISSING_EXTERN_SYMLINK	1
#define MISSING_EXTERN_SYSTEM	1
#define MISSING_EXTERN_TIME	1
#define MISSING_EXTERN_VFPRINTF	1
#define MISSING_EXTERN_VSPRINTF	1

#define MISSING_EXTERN_LSTAT 1
#define MISSING_EXTERN_MUNMAP 1
#define EXIT_FAILURE 1
#define EXIT_SUCCESS 0

