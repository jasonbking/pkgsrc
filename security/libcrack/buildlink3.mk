# $NetBSD: buildlink3.mk,v 1.2 2004/01/04 23:34:07 jlam Exp $

BUILDLINK_DEPTH:=		${BUILDLINK_DEPTH}+
LIBCRACK_BUILDLINK3_MK:=	${LIBCRACK_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	libcrack
.endif

.if !empty(LIBCRACK_BUILDLINK3_MK:M+)
BUILDLINK_PACKAGES+=		libcrack
BUILDLINK_DEPENDS.libcrack?=	libcrack>=2.7
BUILDLINK_PKGSRCDIR.libcrack?=	../../security/libcrack
.endif	# LIBCRACK_BUILDLINK3_MK

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH:C/\+$//}
