# $NetBSD: suse.mk,v 1.6 2000/08/25 00:20:22 jlam Exp $

MASTER_SITE_SUSE=	ftp://ftp.suse.com/pub/suse/i386/6.3/suse/

DIST_SUBDIR?=		suse63

WRKSRC?=		${WRKDIR}
MANCOMPRESSED?=		yes

EMULSUBDIR=		emul/linux
EMULDIR=		${PREFIX}/${EMULSUBDIR}

RPM2PKG=		${PREFIX}/sbin/rpm2pkg

# The SuSE Linux packages have circular dependencies.
LDD?=			${TRUE}	

RPM2PKGARGS=		-d ${PREFIX} -f ${PLIST_SRC} -p ${EMULSUBDIR}
.for TEMP in ${RPMIGNOREPATH}
RPM2PKGARGS+=		-i ${TEMP}
.endfor
.for TEMP in ${RPMFILES}
RPM2PKGARGS+=		${DISTDIR}/${DIST_SUBDIR}/${TEMP}
.endfor

.if !target(do-install)
do-install:
	@if [ -f ${PKGDIR}/PLIST ]; then \
	  ${CP} ${PKGDIR}/PLIST ${PLIST_SRC}; \
	else \
	  ${RM} -f ${PLIST_SRC}; \
	fi
	${RPM2PKG} ${RPM2PKGARGS}
	@if ${GREP} -q 'lib.*\.so' ${PLIST_SRC}; then \
	  ${ECHO_MSG} "===>   [Automatic Linux shared object handling]"; \
	  ${EMULDIR}/sbin/ldconfig -r ${EMULDIR}; \
	  ${ECHO} "@exec %D/${EMULSUBDIR}/sbin/ldconfig -r %D/${EMULSUBDIR}" >>${PLIST_SRC}; \
	  ${ECHO} "@unexec %D/${EMULSUBDIR}/sbin/ldconfig -r %D/${EMULSUBDIR} 2>/dev/null" >>${PLIST_SRC}; \
	fi
.endif

show-shlib-type:
	@${ECHO} linux-${MACHINE_ARCH}

.include "../../mk/bsd.pkg.mk"
