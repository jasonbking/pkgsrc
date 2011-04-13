# $NetBSD: options.mk,v 1.3 2011/04/13 13:23:05 adam Exp $

PKG_OPTIONS_VAR=	PKG_OPTIONS.php-ldap
PKG_SUPPORTED_OPTIONS=	sasl exop

.include "../../mk/bsd.options.mk"

.if !empty(PKG_OPTIONS:Msasl)
USE_BUILTIN.openldap-client=no
.  include "../../databases/openldap-client/builtin.mk"
.  include "../../databases/openldap-client/buildlink3.mk"
.  include "../../security/cyrus-sasl/buildlink3.mk"
CONFIGURE_ARGS+= --with-ldap-sasl=${PREFIX}
.endif

.if !empty(PKG_OPTIONS:Mexop)
USE_TOOLS+=	patch
EXOP_PATCH=	${FILESDIR}/ldap-ctrl-exop.patch
post-patch:
	${PATCH} -d ${WRKSRC} -p2 --forward --quiet  < ${EXOP_PATCH}
.endif
