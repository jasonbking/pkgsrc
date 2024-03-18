$NetBSD$

Silence warning about unused return value

--- src/tss2-fapi/fapi_crypto.c.orig	2024-03-17 22:21:22.933876200 +0000
+++ src/tss2-fapi/fapi_crypto.c
@@ -2081,7 +2081,7 @@ ifapi_base64encode(uint8_t *buffer, size
                    cleanup);
     }
 
-    BIO_flush(bio);
+    (void) BIO_flush(bio);
     BIO_get_mem_ptr(bio, &b64_mem);
     goto_if_null2(b64_mem, "Out of memory.", r, TSS2_FAPI_RC_MEMORY, cleanup);
 
