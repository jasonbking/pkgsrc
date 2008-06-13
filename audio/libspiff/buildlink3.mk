# $NetBSD: buildlink3.mk,v 1.2 2008/06/13 05:14:00 bjs Exp $

BUILDLINK_DEPTH:=		${BUILDLINK_DEPTH}+
LIBSPIFF_BUILDLINK3_MK:=	${LIBSPIFF_BUILDLINK3_MK}+

.if ${BUILDLINK_DEPTH} == "+"
BUILDLINK_DEPENDS+=	libspiff
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Nlibspiff}
BUILDLINK_PACKAGES+=	libspiff
BUILDLINK_ORDER:=	${BUILDLINK_ORDER} ${BUILDLINK_DEPTH}libspiff

.if ${LIBSPIFF_BUILDLINK3_MK} == "+"
BUILDLINK_API_DEPENDS.libspiff+=	libspiff>=0.8.2
BUILDLINK_ABI_DEPENDS.libspiff+=	libspiff>=0.8.3 # XXX soname
BUILDLINK_PKGSRCDIR.libspiff?=	../../audio/libspiff
.endif	# LIBSPIFF_BUILDLINK3_MK

.include "../../textproc/expat/buildlink3.mk"
.include "../../textproc/uriparser/buildlink3.mk"

BUILDLINK_DEPTH:=		${BUILDLINK_DEPTH:S/+$//}
