# $NetBSD: buildlink3.mk,v 1.12 2008/02/18 16:39:43 xtraeme Exp $

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH}+
PNET_BUILDLINK3_MK:=	${PNET_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	pnet
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Npnet}
BUILDLINK_PACKAGES+=	pnet
BUILDLINK_ORDER:=	${BUILDLINK_ORDER} ${BUILDLINK_DEPTH}pnet

.if !empty(PNET_BUILDLINK3_MK:M+)
BUILDLINK_API_DEPENDS.pnet+=	pnet>=0.8.0
BUILDLINK_PKGSRCDIR.pnet?=	../../lang/pnet
.endif	# PNET_BUILDLINK3_MK

.include "../../devel/zlib/buildlink3.mk"

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH:S/+$//}
