# $NetBSD: options.mk,v 1.2 2004/08/22 19:32:52 jlam Exp $

.if defined(SASL_USE_GSSAPI) && !empty(SASL_USE_GSSAPI:M[yY][eE][sS])
PKG_DEFAULT_OPTIONS+=	gssapi
.endif

PKG_OPTIONS_VAR=	PKG_OPTIONS.cyrus-saslauthd
PKG_SUPPORTED_OPTIONS=	PAM kerberos ldap gssapi
.include "../../mk/bsd.options.mk"

###
### PAM (Pluggable Authentication Mechanism)
###
.if !empty(PKG_OPTIONS:MPAM)
.  include "../../security/PAM/buildlink3.mk"
CONFIGURE_ARGS+=	--with-pam=${BUILDLINK_PREFIX.pam}
.endif

###
### Authentication against information stored in an LDAP directory
###
.if !empty(PKG_OPTIONS:Mldap)
.  include "../../databases/openldap/buildlink3.mk"
.  include "../../security/cyrus-sasl2/buildlink3.mk"
BUILDLINK_INCDIRS.cyrus-sasl=	include/sasl
CONFIGURE_ARGS+=	--with-ldap=${BUILDLINK_PREFIX.openldap}
PLIST_SUBST+=		LDAP=
.else
PLIST_SUBST+=		LDAP="@comment "
.endif

###
### Kerberos authentication is via GSSAPI.
###
.if !empty(PKG_OPTIONS:Mkerberos)
.  if empty(PKG_OPTIONS:Mgssapi)
PKG_OPTIONS+=		gssapi
.  endif
.endif

###
### Authentication via GSSAPI (which supports primarily Kerberos 5)
###
.if !empty(PKG_OPTIONS:Mgssapi)
.  include "../../mk/krb5.buildlink3.mk"
CONFIGURE_ARGS+=	--enable-gssapi=${KRB5BASE}
CONFIGURE_ARGS+=	--with-gss_impl=${GSSIMPL.${KRB5_TYPE}}
GSSIMPL.heimdal=	heimdal
GSSIMPL.mit-krb5=	mit
.endif
