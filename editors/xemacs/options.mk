# $NetBSD: options.mk,v 1.3 2005/02/28 16:20:10 uebayasi Exp $

PKG_OPTIONS_VAR=	PKG_OPTIONS.xemacs
PKG_SUPPORTED_OPTIONS=	ldap xface canna

.include "../../mk/bsd.options.mk"

.if !empty(PKG_OPTIONS:Mldap)
CONFIGURE_ARGS=	--with-ldap
.  include "../../databases/openldap/buildlink3.mk"
.else
CONFIGURE_ARGS=	--without-ldap
.endif

.if !empty(PKG_OPTIONS:Mxface)
CONFIGURE_ARGS=	--with-xface
.  include "../../mail/faces/buildlink3.mk"
.else
CONFIGURE_ARGS=	--without-xface
.endif

.if !empty(PKG_OPTIONS:Mcanna)
.  include "../../inputmethod/canna-lib/buildlink3.mk"
CONFIGURE_ARGS=	--with-canna
.else
CONFIGURE_ARGS=	--without-canna
.endif
