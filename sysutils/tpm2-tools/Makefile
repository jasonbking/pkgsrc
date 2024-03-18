# $NetBSD$

DISTNAME=	tpm2-tools-5.6
CATEGORIES=	sysutils
MASTER_SITES=	${MASTER_SITE_GITHUB:=tpm2-software/}
GITHUB_PROJECT=	tpm2-tools
GITHUB_RELEASE=	5.6

MAINTAINER=	jason.brian.king@gmail.com
HOMEPAGE=	https://github.com/tpm2-software/tpm2-tools/
COMMENT=	Trusted Platform Module (TPM2.0) tools
LICENSE=	2-clause-bsd

EGDIR=			${PREFIX}/share/examples/tpm2-tools
INSTALL_MAKE_FLAGS=	${MAKE_FLAGS} bashcompdir=${EGDIR}/bash-completion/completions

USE_LANGUAGES=		c
GNU_CONFIGURE=		yes
USE_LIBTOOL=		yes
USE_TOOLS+=		gmake pkg-config
CONFIGURE_ARGS.SunOS+=	--disable-hardening

.include "../../security/openssl/buildlink3.mk"
.include "../../www/curl/buildlink3.mk"
.include "../../sysutils/tpm2-tss/buildlink3.mk"
.include "../../mk/bsd.pkg.mk"
