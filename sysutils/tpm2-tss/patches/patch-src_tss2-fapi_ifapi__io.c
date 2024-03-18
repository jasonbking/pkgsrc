$NetBSD$

illumos does not have dt_type in struct dirent. Work around by using stat(2)
and abstracting directory iteration as much as is reasonable.

--- src/tss2-fapi/ifapi_io.c.orig	2023-01-23 18:36:16.000000000 +0000
+++ src/tss2-fapi/ifapi_io.c
@@ -31,6 +31,107 @@
 #include "util/log.h"
 #include "util/aux_util.h"
 
+#ifdef __illumos__
+#define DT_UNKNOWN -1
+#define DT_BLK 0
+#define DT_CHR 1
+#define DT_DIR 2
+#define DT_REG 3
+#define DT_FIFO 4
+#define DT_LNK 5
+#define DT_SOCK 6
+#endif
+
+static TSS2_RC
+iterate_dir(
+    const char *dirname,
+    TSS2_RC (*cb)(const char *, const struct dirent *, int, void *),
+    void *arg)
+{
+    DIR *dir;
+    struct dirent *entry;
+    char *path = NULL;
+    int dtype;
+    TSS2_RC r;
+#ifdef __illumos__
+    struct stat sb;
+    int dirfd;
+#endif
+
+#if !defined(__illumos__)
+    if (!(dir = opendir(dirname))) {
+        return_error2(TSS2_FAPI_RC_IO_ERROR, "Could not open directory: %s",
+                      dirname);
+    }
+#else
+    if ((dirfd = open(dirname, O_DIRECTORY|O_RDONLY)) < 0) {
+        return_error2(TSS2_FAPI_RC_IO_ERROR, "Could not open directory: %s",
+                      dirname);
+    }
+    if (!(dir = fdopendir(dirfd))) {
+        close (dirfd);
+        return_error2(TSS2_FAPI_RC_IO_ERROR, "Could not open directory: %s",
+                      dirname);
+    }
+#endif
+
+    while ((entry = readdir(dir)) != NULL) {
+        if (strcmp(entry->d_name, ".") == 0 || strcmp(entry->d_name, "..") == 0)
+            continue;
+
+#if !defined(__illumos__)
+        dtype = entry->d_type;
+#else
+        if (fstatat(dirfd, entry->d_name, &sb, AT_SYMLINK_NOFOLLOW) < 0) {
+            /* skip entries we can't stat */
+            continue;
+        }
+        switch (sb.st_mode & S_IFMT) {
+        case S_IFIFO:
+            dtype = DT_FIFO;
+            break;
+        case S_IFCHR:
+            dtype = DT_CHR;
+            break;
+        case S_IFBLK:
+            dtype = DT_BLK;
+            break;
+        case S_IFDIR:
+            dtype = DT_DIR;
+            break;
+        case S_IFLNK:
+            dtype = DT_LNK;
+            break;
+        case S_IFSOCK:
+            dtype = DT_SOCK;
+            break;
+        case S_IFREG:
+            dtype = DT_REG;
+            break;
+        default:
+            dtype = DT_UNKNOWN;
+            break;
+        }
+#endif
+
+        r = ifapi_asprintf(&path, "%s/%s", dirname, entry->d_name);
+        if (r)
+            closedir(dir);
+        return_if_error(r, "Out of memory");
+
+        if ((r = cb(path, entry, dtype, arg)) != TSS2_RC_SUCCESS) {
+            free(path);
+            closedir(dir);
+            return r;
+        }
+        free(path);
+        path = NULL;
+    }
+
+    closedir(dir);
+    return TSS2_RC_SUCCESS;
+}
+
 /** Start reading a file's complete content into memory in an asynchronous way.
  *
  * @param[in,out] io The input/output context being used for file I/O.
@@ -369,6 +470,35 @@ ifapi_io_remove_file(const char *file)
     return TSS2_RC_SUCCESS;
 }
 
+struct remove_dirs_args {
+    const char *keystore_path;
+    const char *sub_dir;
+};
+
+static TSS2_RC
+remove_dir_cb(
+    const char *path,
+    const struct dirent *entry,
+    int d_type,
+    void *arg)
+{
+    struct remove_dirs_args *rm_arg = arg;
+
+    LOG_TRACE("Deleting directory entry %s", entry->d_name);
+
+    if (d_type == DT_DIR) {
+        return (ifapi_io_remove_directories(path, rm_arg->keystore_path,
+		                                    rm_arg->sub_dir));
+    }
+	
+    LOG_WARNING("Removing: %s", path);
+
+    if (remove(path) != 0)
+        return_error2(TSS2_FAPI_RC_IO_ERROR, "Removing file");
+
+	return TSS2_RC_SUCCESS;
+}
+
 /** Remove a directory recursively; i.e. including its subdirectories.
  *
  * @param[in] dirname The directory to be removed
@@ -387,54 +517,14 @@ ifapi_io_remove_directories(
     const char *keystore_path,
     const char *sub_dir)
 {
-    DIR *dir;
-    struct dirent *entry;
     TSS2_RC r;
-    char *path;
+    struct remove_dirs_args args = { keystore_path, sub_dir };
     size_t len_kstore_path, len_dir_path, diff_len, pos;
 
     LOG_TRACE("Removing directory: %s", dirname);
 
-    if (!(dir = opendir(dirname))) {
-        return_error2(TSS2_FAPI_RC_IO_ERROR, "Could not open directory: %s",
-                      dirname);
-    }
-
-    /* Iterating through the list of entries inside the directory. */
-    while ((entry = readdir(dir)) != NULL) {
-        LOG_TRACE("Deleting directory entry %s", entry->d_name);
-
-        /* Entries . and .. are obviously ignored */
-        if (strcmp(entry->d_name, ".") == 0 || strcmp(entry->d_name, "..") == 0)
-            continue;
-
-        /* If an entry is a directory then we call ourself recursively to remove those */
-        if (entry->d_type == DT_DIR) {
-            r = ifapi_asprintf(&path, "%s/%s", dirname, entry->d_name);
-            goto_if_error(r, "Out of memory", error_cleanup);
-
-            r = ifapi_io_remove_directories(path, keystore_path, sub_dir);
-            free(path);
-            goto_if_error(r, "remove directories.", error_cleanup);
-
-            continue;
-        }
-
-        /* If an entry is a file or symlink or anything else, we remove it */
-        r = ifapi_asprintf(&path, "%s/%s", dirname, entry->d_name);
-        goto_if_error(r, "Out of memory", error_cleanup);
-
-        LOG_WARNING("Removing: %s", path);
-
-        if (remove(path) != 0) {
-            free(path);
-            closedir(dir);
-            return_error2(TSS2_FAPI_RC_IO_ERROR, "Removing file");
-        }
-
-        free(path);
-    }
-    closedir(dir);
+    if ((r = iterate_dir(dirname, remove_dir_cb, &args)) != TSS2_RC_SUCCESS)
+        return r;
 
     /* Check whether current directory is a keystore directory. These directories should
        not be deleted. */
@@ -454,10 +544,6 @@ ifapi_io_remove_directories(
 
     LOG_TRACE("SUCCESS");
     return TSS2_RC_SUCCESS;
-
-error_cleanup:
-    closedir(dir);
-    return r;
 }
 
 /** Enumerate the list of files in a directory.
@@ -478,10 +564,16 @@ ifapi_io_dirfiles(
     char ***files,
     size_t *numfiles)
 {
-    char **paths;
+    char **paths = NULL;
     int numentries = 0;
-    struct dirent **namelist;
+    struct dirent **namelist = NULL;
     size_t numpaths = 0;
+    TSS2_RC r = TSS2_RC_SUCCESS;
+#ifdef __illumos__
+    struct stat sb;
+    int dirfd = -1;
+#endif
+
     check_not_null(dirname);
     check_not_null(files);
     check_not_null(numfiles);
@@ -497,20 +589,42 @@ ifapi_io_dirfiles(
     paths = calloc(numentries, sizeof(*paths));
     check_oom(paths);
 
+#ifdef __illumos__
+    if ((dirfd = open(dirname, O_DIRECTORY|O_RDONLY)) < 0) {
+        goto_error(r, TSS2_FAPI_RC_IO_ERROR, "Could not open directory: %s",
+	 	   error, dirname);
+    }
+#endif
+        
     /* Iterating through the list of entries inside the directory. */
     for (size_t i = 0; i < (size_t) numentries; i++) {
         LOG_TRACE("Looking at %s", namelist[i]->d_name);
+
+#ifdef __illumos__
+        if (fstatat(dirfd, namelist[i]->d_name, &sb, 0) < 0) {
+            goto_error(r, TSS2_FAPI_RC_IO_ERROR, "Could not stat %s/%s: %s",
+                       error, dirname, namelist[i]->d_name, strerror(errno));
+        }
+
+        if (!S_ISREG(sb.st_mode))
+            continue;
+#else
         if (namelist[i]->d_type != DT_REG)
             continue;
+#endif
 
         paths[numpaths] = strdup(namelist[i]->d_name);
         if (!paths[numpaths])
-            goto error_oom;
+            goto_error(r, TSS2_FAPI_RC_MEMORY, "Out of memory", error);
 
         LOG_TRACE("Added %s to the list at index %zi", paths[numpaths], numpaths);
         numpaths += 1;
     }
 
+#ifdef __illumos__
+    close(dirfd);
+#endif
+
     *files = paths;
     *numfiles = numpaths;
 
@@ -521,7 +635,12 @@ ifapi_io_dirfiles(
 
     return TSS2_RC_SUCCESS;
 
-error_oom:
+error:
+#ifdef __illumos__
+    if (dirfd >= 0)
+        close(dirfd);
+#endif
+
     for (int i = 0; i < numentries; i++) {
         free(namelist[i]);
     }
@@ -530,7 +649,55 @@ error_oom:
     for (size_t i = 0; i < numpaths; i++)
         free(paths[i]);
     free(paths);
-    return TSS2_FAPI_RC_MEMORY;
+    return r;
+}
+
+struct dirfiles_all_arg {
+    NODE_OBJECT_T **list;
+    size_t *n;
+};
+
+static TSS2_RC dirfiles_all(const char *dir_name, NODE_OBJECT_T **list, size_t *n);
+
+static TSS2_RC
+dirfiles_all_cb(
+    const char *path,
+    const struct dirent *entry __attribute__((unused)),
+    int d_type,
+    void *arg)
+{
+    struct dirfiles_all_arg *df_arg = arg;
+    NODE_OBJECT_T *second;
+
+    if (d_type == DT_DIR) {
+        LOG_TRACE("Directory: %s", path);
+
+        return (dirfiles_all(path, df_arg->list, df_arg->n));
+    }
+
+    NODE_OBJECT_T *file_obj = calloc(1, sizeof(NODE_OBJECT_T));
+    if (!file_obj) {
+        LOG_ERROR("Out of memory.");
+        return TSS2_FAPI_RC_MEMORY;
+    }
+
+    *(df_arg->n) += 1;
+    /* Add file name to linked list */
+    file_obj->object = strdup(path);
+    if (file_obj->object == NULL) {
+        LOG_ERROR("Out of memory.");
+        SAFE_FREE(file_obj);
+        return TSS2_FAPI_RC_MEMORY;
+    }
+
+    if (*(df_arg->list) != NULL) {
+        second = *(df_arg->list);
+        file_obj->next = second;
+    }
+    *(df_arg->list) = file_obj;
+    LOG_TRACE("File: %s", path);
+
+    return TSS2_RC_SUCCESS;
 }
 
 /** Get a linked list of files in a directory and all sub directories.
@@ -546,70 +713,9 @@ error_oom:
 static TSS2_RC
 dirfiles_all(const char *dir_name, NODE_OBJECT_T **list, size_t *n)
 {
-    DIR *dir;
-    struct dirent *entry;
-    TSS2_RC r;
-    char *path;
-    NODE_OBJECT_T *second;
-
-    if (!(dir = opendir(dir_name))) {
-        return TSS2_RC_SUCCESS;
-    }
+    struct dirfiles_all_arg arg = { list, n };
 
-    /* Iterating through the list of entries inside the directory. */
-    while ((entry = readdir(dir)) != NULL) {
-        path = NULL;
-        if (entry->d_type == DT_DIR) {
-            /* Recursive call for sub directories */
-            if (strcmp(entry->d_name, ".") == 0 || strcmp(entry->d_name, "..") == 0)
-                continue;
-            r = ifapi_asprintf(&path, "%s/%s", dir_name, entry->d_name);
-            if (r)
-                closedir(dir);
-            return_if_error(r, "Out of memory");
-
-            LOG_TRACE("Directory: %s", path);
-            r = dirfiles_all(path, list, n);
-            SAFE_FREE(path);
-            if (r)
-                closedir(dir);
-            return_if_error(r, "get_entities");
-
-        } else {
-            r = ifapi_asprintf(&path, "%s/%s", dir_name, entry->d_name);
-            if (r)
-                closedir(dir);
-            return_if_error(r, "Out of memory");
-
-            NODE_OBJECT_T *file_obj = calloc(sizeof(NODE_OBJECT_T), 1);
-            if (!file_obj) {
-                LOG_ERROR("Out of memory.");
-                SAFE_FREE(path);
-                closedir(dir);
-                return TSS2_FAPI_RC_MEMORY;
-            }
-
-            *n += 1;
-            /* Add file name to linked list */
-            file_obj->object = strdup(path);
-            if (file_obj->object == NULL) {
-                LOG_ERROR("Out of memory.");
-                SAFE_FREE(file_obj);
-                SAFE_FREE(path);
-                closedir(dir);
-                return TSS2_FAPI_RC_MEMORY;
-            }
-            if (*list != NULL) {
-                second = *list;
-                file_obj->next = second;
-            }
-            *list = file_obj;
-            LOG_TRACE("File: %s", path);
-            SAFE_FREE(path);
-        }
-    }
-    closedir(dir);
-    return TSS2_RC_SUCCESS;
+    return (iterate_dir(dir_name, dirfiles_all_cb, &arg));
 }
 
 
