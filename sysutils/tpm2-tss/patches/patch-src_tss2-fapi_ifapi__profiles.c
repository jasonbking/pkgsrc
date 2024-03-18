$NetBSD$

The index(3C) function requires <strings.h>

--- src/tss2-fapi/ifapi_profiles.c.orig	2024-03-17 22:23:08.294936946 +0000
+++ src/tss2-fapi/ifapi_profiles.c
@@ -11,6 +11,7 @@
 #include <stdint.h>
 #include <stdlib.h>
 #include <string.h>
+#include <strings.h>
 
 #include "tss2_common.h"
 
