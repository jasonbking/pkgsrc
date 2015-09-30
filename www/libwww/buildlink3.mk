# $NetBSD: buildlink3.mk,v 1.19 2015/09/30 08:25:37 tnn Exp $

BUILDLINK_TREE+=	libwww

.if !defined(LIBWWW_BUILDLINK3_MK)
LIBWWW_BUILDLINK3_MK:=

BUILDLINK_API_DEPENDS.libwww+=	libwww>=5.3.2nb2
BUILDLINK_ABI_DEPENDS.libwww+=	libwww>=5.4.0nb13
BUILDLINK_PKGSRCDIR.libwww?=	../../www/libwww

.include "../../mk/bsd.fast.prefs.mk"

pkgbase := libwww
.include "../../mk/pkg-build-options.mk"

.if !empty(PKG_BUILD_OPTIONS.libwww:Msocks4)
.include "../../net/socks4/buildlink3.mk"
.endif

.if !empty(PKG_BUILD_OPTIONS.libwww:Mdante)
.include "../../net/dante/buildlink3.mk"
.endif

.include "../../devel/zlib/buildlink3.mk"
.include "../../security/openssl/buildlink3.mk"
.endif # LIBWWW_BUILDLINK3_MK

BUILDLINK_TREE+=	-libwww
