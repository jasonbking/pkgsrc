$NetBSD$

Add proper include for rindex(3C)

--- tools/tpm2_tool.c.orig	2024-03-18 05:32:40.674130667 +0000
+++ tools/tpm2_tool.c
@@ -3,6 +3,7 @@
 #include <stdbool.h>
 #include <stdlib.h>
 #include <string.h>
+#include <strings.h>
 
 #include <openssl/err.h>
 #include <openssl/evp.h>
