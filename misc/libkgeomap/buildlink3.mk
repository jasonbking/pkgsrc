# $NetBSD: buildlink3.mk,v 1.28 2018/01/01 21:18:10 adam Exp $

BUILDLINK_TREE+=	libkgeomap

.if !defined(LIBKGEOMAP_BUILDLINK3_MK)
LIBKGEOMAP_BUILDLINK3_MK:=

BUILDLINK_API_DEPENDS.libkgeomap+=	libkgeomap>=2.5.0
BUILDLINK_ABI_DEPENDS.libkgeomap?=	libkgeomap>=4.13.0nb6
BUILDLINK_PKGSRCDIR.libkgeomap?=	../../misc/libkgeomap

.include "../../misc/marble/buildlink3.mk"
.include "../../x11/kdelibs4/buildlink3.mk"
.endif	# LIBKGEOMAP_BUILDLINK3_MK

BUILDLINK_TREE+=	-libkgeomap
