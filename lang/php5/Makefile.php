# $NetBSD: Makefile.php,v 1.32 2009/02/22 23:38:46 adrianp Exp $
#

.include "../../lang/php5/Makefile.common"

DISTINFO_FILE=	${.CURDIR}/../../lang/php5/distinfo
PATCHDIR=	${.CURDIR}/../../lang/php5/patches

USE_LIBTOOL=		YES
USE_LANGUAGES=		c c++
GNU_CONFIGURE=		YES
BUILD_DEFS+=		VARBASE
PLIST_VARS+=		suhosin

CONFIGURE_ENV+=		EXTENSION_DIR="${PREFIX}/${PHP_EXTENSION_DIR}"

PHP_EXTENSION_DIR=	lib/php/20040412
PLIST_SUBST+=		PHP_EXTENSION_DIR=${PHP_EXTENSION_DIR:Q}

.include "../../mk/bsd.prefs.mk"

CONFIGURE_ARGS+=	--with-config-file-path=${PKG_SYSCONFDIR:Q}
CONFIGURE_ARGS+=	--sysconfdir=${PKG_SYSCONFDIR:Q}
CONFIGURE_ARGS+=	--localstatedir=${VARBASE}

CONFIGURE_ARGS+=	--with-regex=system

CONFIGURE_ARGS+=	--without-mysql
CONFIGURE_ARGS+=	--without-sqlite
CONFIGURE_ARGS+=	--without-iconv
CONFIGURE_ARGS+=	--without-pear

CONFIGURE_ARGS+=	--disable-posix
CONFIGURE_ARGS+=	--disable-dom
CONFIGURE_ARGS+=	--disable-pdo
CONFIGURE_ARGS+=	--disable-json

CONFIGURE_ARGS+=	--enable-xml
CONFIGURE_ARGS+=	--with-libxml-dir=${PREFIX:Q}
.include "../../textproc/libxml2/buildlink3.mk"

# Note: This expression is the same as ${PKGBASE}, but the latter is
# not defined yet, so we cannot use it here.
PKG_OPTIONS_VAR=	PKG_OPTIONS.${PKGNAME:C/-[0-9].*//}
PKG_SUPPORTED_OPTIONS+=	inet6 ssl maintainer-zts suhosin
PKG_SUGGESTED_OPTIONS+=	ssl

SUBST_CLASSES+=		ini
SUBST_STAGE.ini=	post-patch
SUBST_FILES.ini=	php.ini-dist
SUBST_FILES.ini+=	php.ini-recommended
SUBST_SED.ini=		-e "s|\;include_path = \".:/php/includes\"|include_path = \".:${PREFIX}/lib/php\"|g"
SUBST_MESSAGE.ini=	Fixing default ini files.

.include "../../mk/bsd.options.mk"

.if !empty(PKG_OPTIONS:Msuhosin)
PATCH_SITES=		http://download.suhosin.org/
PATCHFILES+=		suhosin-patch-5.2.8-0.9.6.3.patch.gz
PATCH_DIST_STRIP=	-p1
PLIST.suhosin=		yes
MESSAGE_SRC=		${.CURDIR}/../../lang/php5/MESSAGE
MESSAGE_SRC+=		${.CURDIR}/../../lang/php5/MESSAGE.suhosin
.endif

.if !empty(PKG_OPTIONS:Minet6)
CONFIGURE_ARGS+=	--enable-ipv6
.else
CONFIGURE_ARGS+=	--disable-ipv6
.endif

.if !empty(PKG_OPTIONS:Mssl)
.  include "../../security/openssl/buildlink3.mk"
.  if ${OPSYS} == "SunOS"
CONFIGURE_ARGS+=	--with-openssl=yes
LIBS.SunOS+=		-lcrypto
.  else
CONFIGURE_ARGS+=	--with-openssl=${BUILDLINK_PREFIX.openssl}
.  endif
.else
CONFIGURE_ARGS+=	--without-openssl
.endif

.if !empty(PKG_OPTIONS:Mmaintainer-zts)
CONFIGURE_ARGS+=	--enable-maintainer-zts
.endif
