/*=====================================================================*
 |		pimain.c
 | Copyright (c) 1988-1994, Applied Logic Systems, Inc.
 |
 |	default main() that initializes prolog and starts
 |	the development shell.
 *=====================================================================*/

#ifdef HAVE_CONFIG_H
/* In ALS-Prolog source tree */
#include "defs.h"
#else /* !HAVE_CONFIG_H */
/* Not in ALS-Prolog source tree... */
#include "alspi.h"
#include <stdio.h>
#ifdef HAVE_STDARG_H
#include <stdarg.h>
#else
#include <varargs.h>
#endif
#endif /* !HAVE_CONFIG_H */

extern	void	main	PARAMS(( int, char ** ));

/**************
/*
 * To change the window system to something other than the default
 * set WinsTypeStr to one of MOTIF_WIN_STR, OL_WIN_STR,
 * DEC_WIN_STR, NEXT_WIN_STR, DOS_WIN_STR or NO_WIN_STR
 */

#define WIN_STR NO_WIN_STR

#define EXP_DATE 783785378
**************/
#include "pi_cfg.h"

void
main(argc, argv)
    int   argc;
    char **argv;
{
    int   exit_status;

/*****************
#ifdef EXP_DATE
    if ((unsigned long) time(0) >= EXP_DATE) {
	PI_app_printf(PI_app_printf_error, "System validity date passed!\n");
	exit(1);
	}
#endif

    if ((exit_status = PI_prolog_init(WIN_STR, argc, argv)) != 0) {
	PI_app_printf(PI_app_printf_error, "Prolog init failed !\n");
	exit(1);
    }

#if MOTIFWINS || OLWINS || DECWINS || XWINS
    x_init();
    xaux_init();
#endif

#if MOTIFWINS || OLWINS || DECWINS
    xtaux_init();
#endif

#ifdef OLWINS
    ol_init();
    olaux_init();
#endif

#ifdef MOTIFWINS
    motif_init();
    motifaux_init();
#endif

#ifdef DECWINS
    decw_init();
    decwaux_init();
#endif

#ifdef NEXTWINS
    next_init();
    nextaux_init();
#endif

#ifdef PROLOGDBI
    prologdbi_init();
#endif /* PROLOGDBI */
*****************/
#include "pi_init.c"

    if ((exit_status = PI_toplevel()) != 0) {
	PI_app_printf(PI_app_printf_error, "Prolog shell crashed !\n");
	exit(1);
    }

    PI_shutdown();
    exit(0);
}

/*
 * PI_app_printf is called from the prolog environment to display error and
 * warning messages.  The first parameter, messtype, describes the type
 * of message.  These types are defined in alspi.h.  The message type may be
 * used to route the message supplied in va_alist to the place appropriate
 * for the application.
 *
 * Kev's note to ALS implementers:  
 *	We should be careful to only call PI_app_printf once for each
 *	particular message from Prolog.  Also, we should not make
 *	too many assumptions about what kind of device we are writing
 *	to.  In other words, line control information such as \n should
 *	probably be removed from most of our messages.  It will then
 *	be the responsiblity of PI_app_printf to output newlines or
 *	pop up windows or whatever.  It should also be the responsiblity
 *	of PI_app_printf to prepend information about the type of message.
 *	See the fatal error case (below) as an example.
 */


/*VARARGS0 */
void
#ifdef HAVE_STDARG_H
PI_app_printf(int messtype, ...)
#else
PI_app_printf(messtype,va_alist)
    int messtype;
    va_dcl
#endif
{
    va_list args;
    char *fmt;

#ifdef HAVE_STDARG_H
    va_start(args, messtype);
#else
    va_start(args);
#endif

    fmt = va_arg(args, char *);

    switch (messtype) {
	case PI_app_printf_banner :
	case PI_app_printf_informational :
	    vfprintf(stdout, fmt, args);
	    break;
	case PI_app_printf_fatal_error :
	    fprintf(stderr,"\nFatal Error: ");
	    vfprintf(stderr, fmt, args);
	    fprintf(stderr,"\n");
	    break;
	case PI_app_printf_warning :
	case PI_app_printf_error :
	default :
	    vfprintf(stderr, fmt, args);
	    break;
    }
}