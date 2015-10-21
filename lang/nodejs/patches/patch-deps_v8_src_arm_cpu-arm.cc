$NetBSD: patch-deps_v8_src_arm_cpu-arm.cc,v 1.1 2015/10/21 23:46:28 jmcneill Exp $

--- deps/v8/src/arm/cpu-arm.cc.orig	2015-10-13 17:20:07.000000000 +0000
+++ deps/v8/src/arm/cpu-arm.cc
@@ -7,6 +7,9 @@
 #ifdef __QNXNTO__
 #include <sys/mman.h>  // for cache flushing.
 #undef MAP_TYPE
+#elif defined(__NetBSD__)
+#include <sys/types.h>
+#include <machine/sysarch.h> // for cache flushing.
 #else
 #include <sys/syscall.h>  // for cache flushing.
 #endif
@@ -40,6 +43,10 @@ void CpuFeatures::FlushICache(void* star
 #elif V8_OS_QNX
   msync(start, size, MS_SYNC | MS_INVALIDATE_ICACHE);
 
+#elif defined(__NetBSD__)
+  struct arm_sync_icache_args args = { .addr = (uintptr_t)start, .len = size };
+  sysarch(ARM_SYNC_ICACHE, (void *)&args);
+
 #else
   register uint32_t beg asm("r0") = reinterpret_cast<uint32_t>(start);
   register uint32_t end asm("r1") = beg + size;
