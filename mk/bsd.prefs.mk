# $NetBSD: bsd.prefs.mk,v 1.247 2007/04/14 14:17:49 tnn Exp $
#
# Make file, included to get the site preferences, if any.  Should
# only be included by package Makefiles before any .if defined()
# statements or modifications to "passed" variables (CFLAGS, LDFLAGS, ...),
# to make sure any variables defined in /etc/mk.conf, $MAKECONF, or
# the system defaults (sys.mk and bsd.own.mk) are used.

# Do not recursively include mk.conf, redefine OPSYS, include bsd.own.mk, etc.

# Some variables defined here:
# OPSYS
# The operating system name, as returned by ``uname -s''.

.if !defined(BSD_PKG_MK)

# Let mk.conf know that this is pkgsrc.
BSD_PKG_MK=1
__PREFIX_SET__:=${PREFIX}

# Set PATH if not already set
.if !defined(PATH)
PATH=/bin:/usr/bin:/sbin:/usr/sbin
.endif

# Expand MAKE to a full path.
.if !defined(_MAKE)
_MAKE:=	${MAKE}
.  for _dir_ in ${PATH:C/\:/ /g}
.    if empty(_MAKE:M/*)
.      if exists(${_dir_}/${MAKE})
_MAKE:=	${_dir_}/${MAKE}
.      endif
.    endif
.  endfor
.  if !empty(_MAKE:M/*)
MAKEFLAGS+=	_MAKE=${_MAKE:Q}
.  endif
.endif
MAKE:=	${_MAKE}

.if exists(/usr/bin/uname)
UNAME=/usr/bin/uname
.elif exists(/bin/uname)
UNAME=/bin/uname
.else
UNAME=echo Unknown
.endif

.if exists(/usr/bin/cut)
CUT=/usr/bin/cut
.elif exists(/bin/cut)
CUT=/bin/cut
.else
CUT=echo Unknown
.endif

.if !defined(OPSYS)
OPSYS!=			${UNAME} -s | tr -d /-
MAKEFLAGS+=		OPSYS=${OPSYS:Q}
.endif

# The _CMD indirection allows code below to modify these values
# without executing the commands at all.  Later, recursed make
# invocations will skip these blocks entirely thanks to MAKEFLAGS.
.if !defined(OS_VERSION)
_OS_VERSION_CMD=	${UNAME} -r
OS_VERSION=		${_OS_VERSION_CMD:sh}
MAKEFLAGS+=		OS_VERSION=${OS_VERSION:Q}
.endif
.if !defined(LOWER_OS_VERSION)
_LOWER_OS_VERSION_CMD=	echo ${OS_VERSION} | tr 'A-Z' 'a-z'
LOWER_OS_VERSION=	${_LOWER_OS_VERSION_CMD:sh}
MAKEFLAGS+=		LOWER_OS_VERSION=${LOWER_OS_VERSION:Q}
.endif

# Preload these for architectures not in all variations of bsd.own.mk,
# which do not match their GNU names exactly.
GNU_ARCH.arm26?=	arm
GNU_ARCH.arm32?=	arm
GNU_ARCH.i486?=		i386
GNU_ARCH.i586?=		i386
GNU_ARCH.i686?=		i386
GNU_ARCH.m68000?=	m68010
GNU_ARCH.mips?=		mipsel
GNU_ARCH.sh3eb?=	sh
GNU_ARCH.sh3el?=	shle
MACHINE_GNU_ARCH?=	${GNU_ARCH.${MACHINE_ARCH}:U${MACHINE_ARCH}}

.if ${OPSYS} == "NetBSD"
LOWER_OPSYS?=		netbsd

.elif ${OPSYS} == "AIX"
LOWER_ARCH!=		_cpuid=`/usr/sbin/lsdev -C -c processor -S available | sed 1q | awk '{ print $$1 }'`; \
			if /usr/sbin/lsattr -El $$_cpuid | grep ' POWER' >/dev/null 2>&1; then \
				echo rs6000; \
			else \
				echo powerpc; \
			fi
MACHINE_ARCH?=		${LOWER_ARCH}
.  if exists(/usr/bin/oslevel)
_OS_VERSION!=		/usr/bin/oslevel
.  else
_OS_VERSION!=		echo `${UNAME} -v`.`${UNAME} -r`
.  endif
OS_VERSION!=		echo ${_OS_VERSION} | sed -e 's,\([0-9]*\.[0-9]*\).*,\1,'
LOWER_OS_VERSION=	${OS_VERSION}
LOWER_OPSYS_VERSUFFIX=	${_OS_VERSION}
LOWER_OPSYS?=		aix
LOWER_VENDOR?=		ibm

.elif ${OPSYS} == "BSDOS"
LOWER_OPSYS?=		bsdi

.elif ${OPSYS} == "Darwin"
LOWER_OPSYS?=		darwin
LOWER_ARCH!=		${UNAME} -p
MACHINE_ARCH=		${LOWER_ARCH}
MAKEFLAGS+=		LOWER_ARCH=${LOWER_ARCH:Q}
LOWER_OPSYS_VERSUFFIX!=	echo ${LOWER_OS_VERSION} | ${CUT} -c -1
LOWER_VENDOR?=		apple

.elif ${OPSYS} == "DragonFly"
OS_VERSION:=		${OS_VERSION:C/-.*$//}
LOWER_OPSYS?=		dragonfly
LOWER_ARCH!=		${UNAME} -p
MACHINE_ARCH=		${LOWER_ARCH}
MAKEFLAGS+=		LOWER_ARCH=${LOWER_ARCH:Q}
LOWER_VENDOR?=		pc

.elif ${OPSYS} == "FreeBSD"
LOWER_OPSYS?=		freebsd
LOWER_ARCH!=		${UNAME} -p
.  if ${LOWER_ARCH} == "amd64"
MACHINE_ARCH=		x86_64
.  else
MACHINE_ARCH=		${LOWER_ARCH}
.  endif
MAKEFLAGS+=		LOWER_ARCH=${LOWER_ARCH:Q}
LOWER_OPSYS_VERSUFFIX!=	echo ${LOWER_OS_VERSION} | ${CUT} -c -1
.  if ${LOWER_ARCH} == "i386"
LOWER_VENDOR?=		pc
.  endif
LOWER_VENDOR?=		unknown

.elif ${OPSYS} == "Interix"
LOWER_OPSYS?=		interix3
LOWER_VENDOR?=		pc
.  if exists(/usr/lib/libc.so.3.5)
OS_VERSION=		3.5
.  elif exists(/usr/lib/libc.so.3.1)
OS_VERSION=		3.1
.  else
OS_VERSION=		3.0
.  endif
LOWER_OS_VERSION=	${OS_VERSION}

.elif !empty(OPSYS:MIRIX*)
LOWER_ARCH!=		${UNAME} -p
LOWER_OPSYS?=		irix${OS_VERSION}
LOWER_VENDOR?=		sgi

.elif ${OPSYS} == "Linux"
LOWER_OPSYS?=		linux
MACHINE_ARCH:=          ${MACHINE_ARCH:C/i.86/i386/}
MACHINE_ARCH:=		${MACHINE_ARCH:C/ppc/powerpc/}
.  if !defined(LOWER_ARCH)
LOWER_ARCH!=		${UNAME} -m | sed -e 's/i.86/i386/' -e 's/ppc/powerpc/'
.  endif # !defined(LOWER_ARCH)
.  if ${MACHINE_ARCH} == "unknown" || ${MACHINE_ARCH} == ""
MACHINE_ARCH=		${LOWER_ARCH}
MAKEFLAGS+=		LOWER_ARCH=${LOWER_ARCH:Q}
.  endif
.  if exists(/etc/debian_version)
LOWER_VENDOR?=		debian
.  elif exists(/etc/mandrake-release)
LOWER_VENDOR?=		mandrake
.  elif exists(/etc/redhat-version)
LOWER_VENDOR?=		redhat
.  elif exists(/etc/slackware-version)
LOWER_VENDOR?=		slackware
.  elif ${LOWER_ARCH} == "i386"
LOWER_VENDOR?=          pc
.  endif
LOWER_VENDOR?=          unknown

.elif ${OPSYS} == "OSF1"
LOWER_ARCH!=		${UNAME} -p
MAKEFLAGS+=		LOWER_ARCH=${LOWER_ARCH:Q}
MACHINE_ARCH?=		${LOWER_ARCH}
OS_VERSION:=		${OS_VERSION:C/^V//}
LOWER_OPSYS?=		osf${OS_VERSION}
LOWER_VENDOR?=		dec

.elif ${OPSYS} == "HPUX"
OS_VERSION:=		${OS_VERSION:C/^B.//}
.if ${MACHINE_ARCH} == "9000"
MACHINE_ARCH=		hppa
.endif
LOWER_VENDOR=		hp
LOWER_OPSYS?=		hpux${OS_VERSION}

.elif ${OPSYS} == "SunOS"
.  if ${MACHINE_ARCH} == "sparc"
SPARC_TARGET_ARCH?=	sparcv7
.  elif ${MACHINE_ARCH} == "sun4"
MACHINE_ARCH=		sparc
SPARC_TARGET_ARCH?=	sparcv7
.  elif ${MACHINE_ARCH} == "i86pc"
MACHINE_ARCH=		i386
.  elif ${MACHINE_ARCH} == "unknown"
.    if !defined(LOWER_ARCH)
LOWER_ARCH!=		${UNAME} -p
.    endif	# !defined(LOWER_ARCH)
MAKEFLAGS+=		LOWER_ARCH=${LOWER_ARCH:Q}
.  endif
LOWER_VENDOR?=		sun
LOWER_OPSYS?=		solaris
LOWER_OPSYS_VERSUFFIX=	2

.elif !defined(LOWER_OPSYS)
LOWER_OPSYS!=		echo ${OPSYS} | tr A-Z a-z
.endif

# Now commit the [LOWER_]OS_VERSION values computed above, eliding the :sh
LOWER_OS_VERSION:=	${LOWER_OS_VERSION}
OS_VERSION:=		${OS_VERSION}

MAKEFLAGS+=		LOWER_OPSYS=${LOWER_OPSYS:Q}

LOWER_VENDOR?=		# empty ("arch--opsys")
LOWER_ARCH?=		${MACHINE_GNU_ARCH}

MACHINE_PLATFORM?=	${OPSYS}-${OS_VERSION}-${MACHINE_ARCH}
MACHINE_GNU_PLATFORM?=	${LOWER_ARCH}-${LOWER_VENDOR}-${LOWER_OPSYS}${APPEND_ELF}${LOWER_OPSYS_VERSUFFIX}

# Needed to prevent an "install:" target from being created in bsd.own.mk.
NEED_OWN_INSTALL_TARGET=no

# This prevents default use of the cross-tool harness in the "src" tree,
# in the odd possible case of someone extracting "pkgsrc" underneath "src".
USETOOLS=		no
MAKE_ENV+=		USETOOLS=no

# Set this before <bsd.own.mk> does, since it doesn't know about Darwin
.if ${OPSYS} == "Darwin"
OBJECT_FMT?=		Mach-O
.endif

# Load the settings from MAKECONF, which is /etc/mk.conf by default.
.include <bsd.own.mk>

# /usr/share/mk/bsd.own.mk on NetBSD 1.3 does not define OBJECT_FMT
.if !empty(MACHINE_PLATFORM:MNetBSD-1.3*)
.  if ${MACHINE_ARCH} == "alpha" || \
      ${MACHINE_ARCH} == "mipsel" || ${MACHINE_ARCH} == "mipseb" || \
      ${MACHINE_ARCH} == "powerpc" || ${MACHINE_ARCH} == "sparc64"
OBJECT_FMT?=		ELF
.  else
OBJECT_FMT?=		a.out
.  endif
# override what bootstrap-pkgsrc sets, which isn't right for NetBSD
# 1.4.
# XXX other ELF platforms in 1.4 need to be added to here.
.elif !empty(MACHINE_PLATFORM:MNetBSD-1.4*)
.  if ${MACHINE_ARCH} == "alpha" || \
      ${MACHINE_ARCH} == "mipsel" || ${MACHINE_ARCH} == "mipseb" || \
      ${MACHINE_ARCH} == "powerpc" || ${MACHINE_ARCH} == "sparc64"
OBJECT_FMT=		ELF
.  else
OBJECT_FMT=		a.out
.  endif
.endif

.if ${OPSYS} == "OpenBSD"
.  if defined(ELF_TOOLCHAIN) && ${ELF_TOOLCHAIN} == "yes"
OBJECT_FMT?=	ELF
.  else
OBJECT_FMT?=	a.out
.  endif
.elif ${OPSYS} == "DragonFly"
OBJECT_FMT=	ELF
.elif ${OPSYS} == "AIX"
OBJECT_FMT=	XCOFF
.elif ${OPSYS} == "OSF1"
OBJECT_FMT=	ECOFF
.elif ${OPSYS} == "HPUX"
.  if ${MACHINE_ARCH} == "ia64" || (defined(ABI) && ${ABI} == "64")
OBJECT_FMT=	ELF
.  else
OBJECT_FMT=	SOM
.  endif
.endif

# Calculate depth
.if exists(${.CURDIR}/mk/bsd.pkg.mk)
_PKGSRC_TOPDIR=	${.CURDIR}
.elif exists(${.CURDIR}/../mk/bsd.pkg.mk)
_PKGSRC_TOPDIR=	${.CURDIR}/..
.elif exists(${.CURDIR}/../../mk/bsd.pkg.mk)
_PKGSRC_TOPDIR=	${.CURDIR}/../..
.endif

# include the defaults file
.if exists(${_PKGSRC_TOPDIR}/mk/defaults/mk.conf)
.  include "${_PKGSRC_TOPDIR}/mk/defaults/mk.conf"
.endif

.if ${OPSYS} == "NetBSD"
.  if ${OBJECT_FMT} == "ELF" && \
   (${MACHINE_GNU_ARCH} == "arm" || \
    ${MACHINE_ARCH} == "i386" || \
    ${MACHINE_ARCH} == "m68k" || \
    ${MACHINE_ARCH} == "m68000" || \
    ${MACHINE_GNU_ARCH} == "sh" || \
    ${MACHINE_GNU_ARCH} == "shle" || \
    ${MACHINE_ARCH} == "sparc" || \
    ${MACHINE_ARCH} == "vax")
APPEND_ELF=		elf
.  endif
.endif

SHAREOWN?=		${DOCOWN}
SHAREGRP?=		${DOCGRP}
SHAREMODE?=		${DOCMODE}

.if defined(PREFIX) && (${PREFIX} != ${__PREFIX_SET__})
.BEGIN:
	@${ECHO_MSG} "You CANNOT set PREFIX manually or in mk.conf. Set LOCALBASE or X11BASE"
	@${ECHO_MSG} "depending on your needs. See the pkg system documentation for more info."
	@${FALSE}
.endif

# Preload all default values for CFLAGS, LDFLAGS, etc. before bsd.pkg.mk
# or a pkg Makefile modifies them.
.include <sys.mk>

# Load the OS-specific definitions for program variables.  Default to loading
# the NetBSD ones if an OS-specific file doesn't exist.
.if exists(${_PKGSRC_TOPDIR}/mk/platform/${OPSYS}.mk)
.  include "${_PKGSRC_TOPDIR}/mk/platform/${OPSYS}.mk"
.else
.  include "${_PKGSRC_TOPDIR}/mk/platform/NetBSD.mk"
PKG_FAIL_REASON+=	"missing mk/platform/${OPSYS}.mk"
.endif

PKGDIRMODE?=		755

# PKG_DESTDIR_SUPPORT can only be one of "destdir" or "user-destdir".
USE_DESTDIR?=		no
PKG_DESTDIR_SUPPORT?=	# empty

.if empty(PKG_DESTDIR_SUPPORT) || (empty(USE_DESTDIR:M[Yy][Ee][Ss]) && empty(USE_DESTDIR:M[Ff][Uu][Ll][Ll]))
_USE_DESTDIR=		no
.elif ${PKG_DESTDIR_SUPPORT} == "user-destdir"
.  if !empty(USE_DESTDIR:M[Ff][Uu][Ll][Ll])
_USE_DESTDIR=		user-destdir
.  else
_USE_DESTDIR=		destdir
.  endif
.elif ${PKG_DESTDIR_SUPPORT} == "destdir"
_USE_DESTDIR=		destdir
.else
PKG_FAIL_REASON+=	"PKG_DESTDIR_SUPPORT must be \`\`destdir'' or \`\`user-destdir''."
.endif

# When using staged installation, everything gets installed into
# ${DESTDIR}${PREFIX} instead of ${PREFIX} directly.
#
.if ${_USE_DESTDIR} != "no"
DESTDIR=		${WRKDIR}/.destdir
.  if ${_USE_DESTDIR} == "destdir"
_MAKE_PACKAGE_AS_ROOT=	yes
_MAKE_CLEAN_AS_ROOT=	yes
_MAKE_INSTALL_AS_ROOT=	yes
.  elif ${_USE_DESTDIR} == "user-destdir"
_MAKE_PACKAGE_AS_ROOT=	no
_MAKE_CLEAN_AS_ROOT=	no
_MAKE_INSTALL_AS_ROOT=	no
.  endif
.else
DESTDIR=
.endif

_MAKE_CLEAN_AS_ROOT?=	no
# Whether to run the clean target as root.
_MAKE_INSTALL_AS_ROOT?=	yes
# Whether to run the install target as root.
_MAKE_PACKAGE_AS_ROOT?=	yes
# Whether to run the package target as root.

PKG_INSTALLATION_TYPES?= overwrite
# This is a whitespace-separated list of installation types supported
# by the package.
#
# *NOTE*: This variable *must* be set in the package Makefile *before*
#         the inclusion of bsd.prefs.mk.
#
# Possible: any of: overwrite, pkgviews
# Default: overwrite

# Set the style of installation to be performed for the package.  The
# funky make variable modifiers just select the first word of the value
# stored in the referenced variable.
#
.for _pref_ in ${PKG_INSTALLATION_PREFS}
.  if !empty(PKG_INSTALLATION_TYPES:M${_pref_})
PKG_INSTALLATION_TYPE?=	${PKG_INSTALLATION_TYPES:M${_pref_}:S/^/_pkginsttype_/1:M_pkginsttype_*:S/^_pkginsttype_//}
.  endif
.endfor
PKG_INSTALLATION_TYPE?=	none

# if the system is IPv6-ready, compile with IPv6 support turned on.
.if defined(USE_INET6)
.  if empty(USE_INET6:M[Yy][Ee][Ss])
USE_INET6=		NO
.  else
USE_INET6=		YES
.  endif
.elif empty(_OPSYS_HAS_INET6:M[nN][oO])
USE_INET6=		YES
.else
USE_INET6=		NO
.endif

LOCALBASE?=		/usr/pkg
X11_TYPE?=		native
.if !empty(X11_TYPE:Mnative)
.  if ${OPSYS} == "SunOS"
# On Solaris, we default to using OpenWindows for X11.
X11BASE?=	/usr/openwin
.  elif ${OPSYS} == "IRIX" || ${OPSYS} == "OSF1" || ${OPSYS} == "HPUX"
X11BASE?=	/usr
.  else
X11BASE?=	/usr/X11R6
.  endif
.endif
CROSSBASE?=	${LOCALBASE}/cross

# If xpkgwedge.def is found, then clearly we're using xpkgwedge.
.if exists(${LOCALBASE}/lib/X11/config/xpkgwedge.def) || \
    exists(${X11BASE}/lib/X11/config/xpkgwedge.def)
USE_XPKGWEDGE=  yes
.elif defined(_OPSYS_NEEDS_XPKGWEDGE) && \
    !empty(_OPSYS_NEEDS_XPKGWEDGE:M[yY][eE][sS])
USE_XPKGWEDGE=	yes
.elif ${PKG_INSTALLATION_TYPE} == "pkgviews"
USE_XPKGWEDGE=		yes
.elif ${X11_TYPE} == "modular"
USE_XPKGWEDGE=	no
.else
USE_XPKGWEDGE?=	yes
.endif

# Default installation prefix for meta-pkgs/xorg.
.if defined(X11_TYPE) && !empty(X11_TYPE:Mxorg)
X11ROOT_PREFIX?=	xorg
.else
X11ROOT_PREFIX?=	# empty
.endif

.if ${X11_TYPE} == "xorg"
X11BASE?=		${LOCALBASE}/${X11ROOT_PREFIX}
.elif ${X11_TYPE} == "modular"
X11BASE=		${LOCALBASE}
.endif

.if !empty(USE_XPKGWEDGE:M[Yy][Ee][Ss])
X11PREFIX=		${LOCALBASE}
.else
X11PREFIX=		${X11BASE}
.endif

# Default directory for font encodings
X11_ENCODINGSDIR?=	${X11BASE}/lib/X11/fonts/encodings

DEPOT_SUBDIR?=		packages
DEPOTBASE=		${LOCALBASE}/${DEPOT_SUBDIR}

# LINK_RPATH_FLAG publicly exports the linker flag used to set the
# run-time library search path.
#
.if defined(_OPSYS_LINKER_RPATH_FLAG)
LINKER_RPATH_FLAG=	${_OPSYS_LINKER_RPATH_FLAG}
.else
LINKER_RPATH_FLAG?=	${_LINKER_RPATH_FLAG}
.endif

# COMPILER_RPATH_FLAG publicly exports the compiler flag used to pass
# run-time library search path directives to the linker.
#
.if defined(_OPSYS_COMPILER_RPATH_FLAG)
COMPILER_RPATH_FLAG=	${_OPSYS_COMPILER_RPATH_FLAG}
.else
COMPILER_RPATH_FLAG?=	${_COMPILER_RPATH_FLAG}
.endif

# WHOLE_ARCHIVE_FLAG and NO_WHOLE_ARCHIVE_FLAG publically export the
# linker flags to extract all symbols from a static archive.
WHOLE_ARCHIVE_FLAG?=	${_OPSYS_WHOLE_ARCHIVE_FLAG}
NO_WHOLE_ARCHIVE_FLAG?=	${_OPSYS_NO_WHOLE_ARCHIVE_FLAG}

USE_TOOLS?=	# empty

# Provide default values for TOOLs used by the top-level make.
USE_TOOLS+=	[ awk dirname echo grep pwd sed test true

# These tools are used by the top-level make only in certain packages and
# should eventually be moved into those particular package Makefiles.
#
USE_TOOLS+=	date tr

# These are tools used directly by bsd.prefs.mk and files included by
# bsd.prefs.mk.
#
USE_TOOLS+=	awk:pkgsrc cut:pkgsrc echo:pkgsrc pwd:pkgsrc		\
		sed:pkgsrc tr:pkgsrc uname:pkgsrc

.include "${_PKGSRC_TOPDIR}/mk/tools/defaults.mk"

.if exists(${LOCALBASE}/bsd/share/mk/zoularis.mk)
PKG_FAIL_REASON+=	'You appear to have a deprecated Zoularis installation.'
PKG_FAIL_REASON+=	'Please update your system to bootstrap-pkgsrc and remove the'
PKG_FAIL_REASON+=	'${LOCALBASE}/bsd directory.'
PKG_FAIL_REASON+=	'See http://mail-index.NetBSD.org/tech-pkg/2004/02/14/0004.html'
PKG_FAIL_REASON+=	'for more details.'
.endif

PKGPATH?=		${.CURDIR:C|.*/([^/]*/[^/]*)$|\1|}
.if !defined(_PKGSRCDIR)
_PKGSRCDIR!=		cd ${_PKGSRC_TOPDIR} && ${PWD_CMD}
MAKEFLAGS+=		_PKGSRCDIR=${_PKGSRCDIR:Q}
.endif
PKGSRCDIR=		${_PKGSRCDIR}

DISTDIR?=		${PKGSRCDIR}/distfiles
PACKAGES?=		${PKGSRCDIR}/packages
TEMPLATES?=		${PKGSRCDIR}/templates

PATCHDIR?=		${.CURDIR}/patches
FILESDIR?=		${.CURDIR}/files
PKGDIR?=		${.CURDIR}

_PKGSRC_DEPS?=		# empty

# If WRKOBJDIR is set, use that tree to build
.if defined(WRKOBJDIR)
BUILD_DIR?=		${WRKOBJDIR}/${PKGPATH}
.else
BUILD_DIR!=		cd ${.CURDIR} && ${PWD_CMD}
.endif

# If OBJHOSTNAME is set, use first component of hostname in directory name.
# If OBJMACHINE is set, use ${MACHINE_ARCH} in the working directory name.
#
.if defined(OBJHOSTNAME)
.  if !defined(_HOSTNAME)
_HOSTNAME!=		${UNAME} -n
MAKEFLAGS+=		_HOSTNAME=${_HOSTNAME:Q}
.  endif
WRKDIR_BASENAME?=	work.${_HOSTNAME:C|\..*||}
MAKEFLAGS+=		OBJHOSTNAME=${OBJHOSTNAME:Q}
.elif defined(OBJMACHINE)
WRKDIR_BASENAME?=	work.${MACHINE_ARCH}
MAKEFLAGS+=		OBJMACHINE=${OBJMACHINE:Q}
.else
WRKDIR_BASENAME?=	work
.endif

WRKDIR?=		${BUILD_DIR}/${WRKDIR_BASENAME}

# There are many uses for a common log file, so define one that may be
# picked up and used by tools.mk, bsd.buildlink3.mk, etc.
#
WRKLOG?=		${WRKDIR}/.work.log

PKG_DEFAULT_OPTIONS?=	# empty
PKG_OPTIONS?=		# empty

# we want this *before* compiler.mk, so that compiler.mk paths override them
.if ${X11_TYPE} != "modular" && defined(USE_X11)
PREPEND_PATH+=		${X11BASE}/bin
.endif
PREPEND_PATH+=		${LOCALBASE}/bin

# Wrapper framework definitions
.include "${PKGSRCDIR}/mk/wrapper/wrapper-defs.mk"

# Package system flavor definitions
.include "${PKGSRCDIR}/mk/flavor/bsd.flavor-vars.mk"

# Make variable definitions cache
.include "${PKGSRCDIR}/mk/bsd.makevars.mk"

# If MAKECONF is defined, then pass it down to all recursive make
# processes invoked by pkgsrc.
#
PKGSRC_MAKE_ENV+=	${MAKECONF:DMAKECONF=${MAKECONF:Q}}
RECURSIVE_MAKE=		${SETENV} ${PKGSRC_MAKE_ENV} ${MAKE}

.endif	# BSD_PKG_MK
