# $NetBSD: buildlink3.mk,v 1.2 2004/01/04 23:34:07 jlam Exp $

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH}+
EXPAT_BUILDLINK3_MK:=	${EXPAT_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	expat
.endif

.if !empty(EXPAT_BUILDLINK3_MK:M+)
BUILDLINK_PACKAGES+=		expat
BUILDLINK_DEPENDS.expat?=	expat>=1.95.4
BUILDLINK_PKGSRCDIR.expat?=	../../textproc/expat
.endif	# EXPAT_BUILDLINK3_MK

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH:C/\+$//}
