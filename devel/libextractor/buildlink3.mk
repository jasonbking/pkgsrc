# $NetBSD: buildlink3.mk,v 1.1 2004/11/05 18:26:19 tv Exp $

BUILDLINK_DEPTH:=		${BUILDLINK_DEPTH}+
LIBEXTRACTOR_BUILDLINK3_MK:=	${LIBEXTRACTOR_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	libextractor
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Nlibextractor}
BUILDLINK_PACKAGES+=	libextractor

.if !empty(LIBEXTRACTOR_BUILDLINK3_MK:M+)
BUILDLINK_DEPENDS.libextractor+=	libextractor>=0.3.10
BUILDLINK_PKGSRCDIR.libextractor?=	../../devel/libextractor
.endif	# LIBEXTRACTOR_BUILDLINK3_MK

BUILDLINK_DEPTH:=     ${BUILDLINK_DEPTH:S/+$//}
