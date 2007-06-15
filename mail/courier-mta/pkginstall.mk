# $NetBSD: pkginstall.mk,v 1.3 2007/06/15 18:29:06 jlam Exp $

# Convenience definition used below for a file or directory owned by the
# courier user and group.
#
COURIER_OWNED=		${COURIER_USER} ${COURIER_GROUP}

REQD_DIRS+=		${DATADIR} ${DOCDIR} ${EGDIR}			\
			${LIBEXECDIR} ${LIBEXECDIR}/modules
REQD_DIRS_PERMS+=	${LIBEXECDIR}/cgi-bin				\
				${REAL_ROOT_USER} ${REAL_ROOT_GROUP} 0700
MAKE_DIRS+=		${VARBASE}/run ${COURIER_STATEDIR}

###
### Courier filter directories
###
OWN_DIRS_PERMS+=	${PKG_SYSCONFDIR}/filters	${COURIER_OWNED} 0750
OWN_DIRS_PERMS+=	${PKG_SYSCONFDIR}/filters/active		\
							${COURIER_OWNED} 0750
OWN_DIRS_PERMS+=	${COURIER_STATEDIR}/allfilters	${COURIER_OWNED} 0750
OWN_DIRS_PERMS+=	${COURIER_STATEDIR}/filters	${COURIER_OWNED} 0750

###
### Courier mail submission directories
###
OWN_DIRS_PERMS+=	${COURIER_STATEDIR}/msgq	${COURIER_OWNED} 0750
OWN_DIRS_PERMS+=	${COURIER_STATEDIR}/msgs	${COURIER_OWNED} 0750
OWN_DIRS_PERMS+=	${COURIER_STATEDIR}/tmp		${COURIER_OWNED} 0770
OWN_DIRS_PERMS+=	${COURIER_STATEDIR}/track	${COURIER_OWNED} 0755

###
### Courier webadmin directories
###
OWN_DIRS_PERMS+=	${COURIER_STATEDIR}/webadmin	${COURIER_OWNED} 0700
OWN_DIRS_PERMS+=	${COURIER_STATEDIR}/webadmin/added		\
							${COURIER_OWNED} 0700
OWN_DIRS_PERMS+=	${COURIER_STATEDIR}/webadmin/removed		\
							${COURIER_OWNED} 0700

###
### Courier setuid and setgid binaries
###
SPECIAL_PERMS+=		bin/cancelmsg			${COURIER_OWNED} 6555
SPECIAL_PERMS+=		bin/mailq			${COURIER_OWNED} 2555
SPECIAL_PERMS+=		bin/sendmail			${SETUID_ROOT_PERMS}
SPECIAL_PERMS+=		libexec/courier/cgi-bin/courierwebadmin		\
							${SETUID_ROOT_PERMS}
SPECIAL_PERMS+=		libexec/courier/submitmkdir	${COURIER_OWNED} 4550

###
### Courier delivery configuration directories
###
OWN_DIRS_PERMS+=	${PKG_SYSCONFDIR}/aliasdir	${COURIER_OWNED} 0755
OWN_DIRS_PERMS+=	${PKG_SYSCONFDIR}/aliases	${COURIER_OWNED} 0750
OWN_DIRS_PERMS+=	${PKG_SYSCONFDIR}/smtpaccess	${COURIER_OWNED} 0755

.for _file_ in		aliases/system
CONF_FILES_PERMS+=	${EGDIR}/${_file_} ${PKG_SYSCONFDIR}/${_file_}	\
							${COURIER_OWNED} 0640
.endfor
.for _file_ in		courierd.dist enablefiltering locallowercase	\
			maildrop maildropfilter rfcerr2045.txt		\
			rfcerr2046.txt rfcerr2047.txt rfcerrheader.txt	\
			smtpaccess/default
CONF_FILES_PERMS+=	${EGDIR}/${_file_}				\
			${PKG_SYSCONFDIR}/${_file_:S/.dist$//}		\
							${COURIER_FILE_PERMS}
.endfor

RCD_SCRIPTS+=		courier courierd courierfilter
