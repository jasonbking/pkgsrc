# $NetBSD: buildlink3.mk,v 1.1 2014/04/22 20:46:41 ryoon Exp $

BUILDLINK_TREE+=	gcc48-fortran

.if !defined(GCC48_FORTRAN_BUILDLINK3_MK)
GCC48_FORTRAN_BUILDLINK3_MK:=

BUILDLINK_API_DEPENDS.gcc48-fortran+=	gcc48-fortran>=${_GCC_REQD}
BUILDLINK_PKGSRCDIR.gcc48-fortran?=	../../lang/gcc48-fortran

BUILDLINK_GCC48_LIBDIRS=		gcc48/lib
BUILDLINK_LIBDIRS.gcc48-fortran+=	${BUILDLINK_GCC48_LIBDIRS}
BUILDLINK_DEPMETHOD.gcc48-fortran?=	build
.endif	# GCC48_FORTRAN_BUILDLINK3_MK

BUILDLINK_TREE+=	-gcc48-fortran
