# $NetBSD: buildlink3.mk,v 1.28 2011/07/08 11:03:36 drochner Exp $

BUILDLINK_TREE+=	gnome-vfs

.if !defined(GNOME_VFS_BUILDLINK3_MK)
GNOME_VFS_BUILDLINK3_MK:=

BUILDLINK_API_DEPENDS.gnome-vfs+=	gnome-vfs>=2.8.0
BUILDLINK_ABI_DEPENDS.gnome-vfs+=	gnome-vfs>=2.24.4nb3
BUILDLINK_PKGSRCDIR.gnome-vfs?=		../../sysutils/gnome-vfs

.include "../../devel/GConf/buildlink3.mk"
.include "../../devel/glib2/buildlink3.mk"
.include "../../devel/zlib/buildlink3.mk"
.include "../../security/openssl/buildlink3.mk"
.include "../../sysutils/dbus-glib/buildlink3.mk"

pkgbase := gnome-vfs
.include "../../mk/pkg-build-options.mk"

.if !empty(PKG_BUILD_OPTIONS.gnome-vfs:Mavahi)
.include "../../net/avahi/buildlink3.mk"
.endif

.if !empty(PKG_BUILD_OPTIONS.gnome-vfs:Mfam)
.include "../../mk/fam.buildlink3.mk"
.endif

.endif # GNOME_VFS_BUILDLINK3_MK

BUILDLINK_TREE+=	-gnome-vfs
