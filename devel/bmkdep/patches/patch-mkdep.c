$NetBSD: patch-mkdep.c,v 1.5 2014/01/13 00:01:12 cheusov Exp $

Always use portable snprintf
--- mkdep.c.orig	2013-12-15 19:47:07.000000000 +0000
+++ mkdep.c
@@ -52,7 +52,6 @@ __RCSID("$NetBSD: mkdep.c,v 1.43 2013/03
 
 #ifndef __sun
 #include <paths.h>
-#define _WITH_DPRINTF
 #endif
 
 #include <stdio.h>
@@ -343,14 +342,9 @@ main(int argc, char **argv)
 			} else
 				fname = *argv++;
 			if (iflag) {
-#ifdef _WITH_DPRINTF
-				if (dprintf(dependfile, ".-include \"%s\"\n",
-				    fname) < 0)
-#else
 				snprintf (incl, sizeof (incl),
 				    ".-include \"%s\"\n", fname);
 				if (write(dependfile, incl, strlen(incl)) < 0)
-#endif
 					goto wrerror;
 				continue;
 			}
