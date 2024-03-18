# $NetBSD$

DISTNAME=	tpm2-tss-4.0.1
CATEGORIES=	sysutils
MASTER_SITES=	${MASTER_SITE_GITHUB:=tpm2-software/}
GITHUB_PROJECT=	tpm2-tss
GITHUB_RELEASE=	4.0.1

MAINTAINER=	jason.brian.king@gmail.com
HOMEPAGE=	https://github.com/tpm2-software/tpm2-tss/
COMMENT=	OSS implementation of the TCG TPM2 Software Stack (TSS2)
LICENSE=	2-clause-bsd

USE_LANGUAGES=		c
GNU_CONFIGURE=		yes
USE_LIBTOOL=		yes
USE_TOOLS+=		gmake pkg-config
# The configure script appends tpm2-tss for install
CONFIGURE_ARGS+=	--sysconfdir=${PKG_SYSCONFBASE}

PKG_SYSCONFSUBDIR=	tpm2-tss
EGDIR=			${PREFIX}/share/examples/tpm2-tss
CONF_FILES=		${EGDIR}/fapi-config.json ${PKG_SYSCONFDIR}/fapi-config.json
CONF_FILES+=		${EGDIR}/fapi-profiles/P_ECCP256SHA256.json ${PKG_SYSCONFDIR}/fapi-profiles/P_ECCP256SHA256.json
CONF_FILES+=		${EGDIR}/fapi-profiles/P_RSA2048SHA256.json ${PKG_SYSCONFDIR}/fapi-profiles/P_RSA2048SHA256.json
MAKE_DIRS+=		${PKG_SYSCONFDIR}/fapi-profiles

INSTALL_MAKE_FLAGS=	${MAKE_FLAGS} fapiconfdir=${EGDIR} fapiprofilesdir=${EGDIR}/fapi-profiles

#
# There appear to be a $PREFIX/var/tpm2-tss/system/keystore that should be 2755 tss:tss
# however not sure how that works with the library so save this stuff for later.
#PKG_GROUPS?=		tss
#PKG_USERS?=		tss:tss
#PKG_GECOS.tpm=		tss user for tpm2
#PKG_HOME.tpm=		/

PKGCONFIG_OVERRIDE+=	lib/tss2-esys.pc.in
PKGCONFIG_OVERRIDE+=	lib/tss2-fapi.pc.in
PKGCONFIG_OVERRIDE+=	lib/tss2-mu.pc.in
PKGCONFIG_OVERRIDE+=	lib/tss2-policy.pc.in
PKGCONFIG_OVERRIDE+=	lib/tss2-rc.pc.in
PKGCONFIG_OVERRIDE+=	lib/tss2-sys.pc.in
PKGCONFIG_OVERRIDE+=	lib/tss2-tcti-cmd.pc.in
PKGCONFIG_OVERRIDE+=	lib/tss2-tcti-device.pc.in
PKGCONFIG_OVERRIDE+=	lib/tss2-tcti-libtpms.pc.in
PKGCONFIG_OVERRIDE+=	lib/tss2-tcti-mssim.pc.in
PKGCONFIG_OVERRIDE+=	lib/tss2-tcti-pcap.pc.in
PKGCONFIG_OVERRIDE+=	lib/tss2-tcti-spi-helper.pc.in
PKGCONFIG_OVERRIDE+=	lib/tss2-tcti-swtpm.pc.in
PKGCONFIG_OVERRIDE+=	lib/tss2-tctildr.pc.in

.include "../../security/openssl/buildlink3.mk"
.include "../../textproc/json-c/buildlink3.mk"
.include "../../www/curl/buildlink3.mk"
.include "../../devel/libuuid/buildlink3.mk"
.include "../../mk/bsd.pkg.mk"
