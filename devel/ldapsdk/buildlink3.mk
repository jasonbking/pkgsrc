# $NetBSD: buildlink3.mk,v 1.1 2004/04/27 04:59:42 snj Exp $

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH}+
LDAPSDK_BUILDLINK3_MK:=	${LDAPSDK_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	ldapsdk
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Nldapsdk}
BUILDLINK_PACKAGES+=	ldapsdk

.if !empty(LDAPSDK_BUILDLINK3_MK:M+)
BUILDLINK_DEPENDS.ldapsdk+=	ldapsdk>=12311998
BUILDLINK_PKGSRCDIR.ldapsdk?=	../../devel/ldapsdk
.endif	# LDAPSDK_BUILDLINK3_MK

BUILDLINK_DEPTH:=     ${BUILDLINK_DEPTH:S/+$//}
