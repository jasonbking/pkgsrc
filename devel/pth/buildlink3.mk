# $NetBSD: buildlink3.mk,v 1.2 2004/01/04 23:34:05 jlam Exp $

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH}+
PTH_BUILDLINK3_MK:=	${PTH_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	pth
.endif

.if !empty(PTH_BUILDLINK3_MK:M+)
BUILDLINK_PACKAGES+=		pth
BUILDLINK_DEPENDS.pth?=		pth>=2.0.0
BUILDLINK_PKGSRCDIR.pth?=	../../devel/pth
.endif	# PTH_BUILDLINK3_MK

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH:C/\+$//}
