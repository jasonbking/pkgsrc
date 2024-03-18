$NetBSD$

Limit tpmrm0 device to Linux

--- src/tss2-tcti/tcti-device.c.orig	2024-03-30 06:07:04.107066435 +0000
+++ src/tss2-tcti/tcti-device.c
@@ -61,7 +61,9 @@ static char *default_conf[] = {
 #ifdef __VXWORKS__
     "/tpm0"
 #else
+#ifdef __linux__
     "/dev/tpmrm0",
+#endif
     "/dev/tpm0",
 #endif /* __VX_WORKS__ */
 };
