# $NetBSD: buildlink3.mk,v 1.2 2004/01/04 23:34:05 jlam Exp $

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH}+
GETTEXT_BUILDLINK3_MK:=	${GETTEXT_BUILDLINK3_MK}+

.if !empty(GETTEXT_BUILDLINK3_MK:M+)
.  include "../../mk/bsd.prefs.mk"

BUILDLINK_DEPENDS.gettext?=	gettext-lib>=0.10.35nb1
BUILDLINK_PKGSRCDIR.gettext?=	../../devel/gettext-lib
.endif	# GETTEXT_BUILDLINK3_MK

BUILDLINK_CHECK_BUILTIN.gettext?=	NO

.if !defined(BUILDLINK_IS_BUILTIN.gettext)
BUILDLINK_IS_BUILTIN.gettext=	NO
.  if exists(/usr/include/libintl.h)
BUILDLINK_IS_BUILTIN.gettext=	YES
.  endif
.endif

.if !empty(BUILDLINK_CHECK_BUILTIN.gettext:M[yY][eE][sS])
_NEED_GNU_GETTEXT=	NO
.endif

.if !defined(_NEED_GNU_GETTEXT)
.  if !empty(BUILDLINK_IS_BUILTIN.gettext:M[nN][oO])
_NEED_GNU_GETTEXT=	YES
.  else
#
# Consider the base system libintl to be gettext-lib-0.10.35nb1.
#
_GETTEXT_PKG=		gettext-lib-0.10.35nb1
_GETTEXT_DEPENDS=	${BUILDLINK_DEPENDS.gettext}
_NEED_GNU_GETTEXT!=	\
	if ${PKG_ADMIN} pmatch '${_GETTEXT_DEPENDS}' ${_GETTEXT_PKG}; then \
		${ECHO} "NO";						\
	else								\
		${ECHO} "YES";						\
	fi
#
# The listed platforms have a broken (for the purposes of pkgsrc) version
# of gettext-lib.  
#
_INCOMPAT_GETTEXT=	SunOS-*-*
INCOMPAT_GETTEXT?=	# empty
.    for _pattern_ in ${_INCOMPAT_GETTEXT} ${INCOMPAT_GETTEXT}
.      if !empty(MACHINE_PLATFORM:M${_pattern_})
_NEED_GNU_GETTEXT=	YES
.      endif
.    endfor
.  endif
MAKEFLAGS+=	_NEED_GNU_GETTEXT=${_NEED_GNU_GETTEXT}
.endif

.if !defined(_BLNK_LIBINTL_FOUND)
_BLNK_LIBINTL_FOUND!=	\
	if [ "`${ECHO} /usr/lib/libintl.*`" = "/usr/lib/libintl.*" ]; then \
		${ECHO} NO;						\
	else								\
		${ECHO} YES;						\
	fi
MAKEFLAGS+=	_BLNK_LIBINTL_FOUND=${_BLNK_LIBINTL_FOUND}
.endif

.if ${_NEED_GNU_GETTEXT} == "YES"
.  if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	gettext
.  endif
.endif

.if !empty(GETTEXT_BUILDLINK3_MK:M+)
.  if ${_NEED_GNU_GETTEXT} == "YES"
BUILDLINK_PACKAGES+=	gettext
_BLNK_LIBINTL=		-lintl
_GETTEXT_ICONV_DEPENDS=	gettext-lib>=0.11.5nb1
.    if !defined(_GETTEXT_NEEDS_ICONV)
_GETTEXT_NEEDS_ICONV!=	\
	if ${PKG_INFO} -qe "${BUILDLINK_DEPENDS.gettext}"; then		\
		pkg=`cd ${_PKG_DBDIR}; ${PKG_ADMIN} -s "" lsbest '${BUILDLINK_DEPENDS.gettext}'`; \
		if ${PKG_INFO} -qN "$$pkg" | ${GREP} -q "libiconv-[0-9]"; then \
			${ECHO} YES;					\
		else							\
			${ECHO} NO;					\
		fi;							\
	else								\
		${ECHO} YES;						\
	fi
MAKEFLAGS+=	_GETTEXT_NEEDS_ICONV=${_GETTEXT_NEEDS_ICONV}
.    endif
.    if ${_GETTEXT_NEEDS_ICONV} == "YES"
.      include "../../converters/libiconv/buildlink3.mk"
BUILDLINK_DEPENDS.gettext=	${_GETTEXT_ICONV_DEPENDS}
_BLNK_LIBINTL+=			${BUILDLINK_LDADD.iconv}
.    endif
.  else
BUILDLINK_PREFIX.gettext=	/usr
.    if ${_BLNK_LIBINTL_FOUND} == "YES"
_BLNK_LIBINTL=		-lintl
.    else
_BLNK_LIBINTL=		# empty
BUILDLINK_TRANSFORM+=	S:-lintl:
.    endif
.  endif

BUILDLINK_LDADD.gettext?=	${_BLNK_LIBINTL}

# Add -lintl to LIBS in CONFIGURE_ENV to work around broken gettext.m4:
# older gettext.m4 does not add -lintl where it should, and the resulting
# configure script fails to detect if libintl.a is the genuine GNU gettext
# or not.
#
.  if defined(GNU_CONFIGURE)
LIBS+=			${BUILDLINK_LDADD.gettext}
CONFIGURE_ENV+=		INTLLIBS="${BUILDLINK_LDADD.gettext}"
.    if ${_NEED_GNU_GETTEXT} == "NO"
.      if ${_BLNK_LIBINTL_FOUND} == "YES"
CONFIGURE_ENV+=		gt_cv_func_gnugettext1_libintl="yes"
.      endif
.    endif
.    if ${_NEED_GNU_GETTEXT} == "YES"
CONFIGURE_ARGS+=	--with-libintl-prefix=${BUILDLINK_PREFIX.gettext}
.    else
CONFIGURE_ARGS+=	--without-libintl-prefix
.    endif
.  endif
.endif	# GETTEXT_BUILDLINK3_MK

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH:C/\+$//}
