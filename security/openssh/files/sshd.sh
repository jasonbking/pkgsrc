#!/bin/sh
#
# $NetBSD: sshd.sh,v 1.1 2000/01/27 17:37:19 hubertf Exp $
#
if [ ! -f @SSH_CONF_DIR@/ssh_host_key ]
then
 @PREFIX@/bin/ssh-keygen -f @SSH_CONF_DIR@/ssh_host_key -N ''
fi
if [ -x @PREFIX@/sbin/sshd -a -f @SSH_CONF_DIR@/sshd_config ]
then
 @PREFIX@/sbin/sshd
 echo -n ' sshd'
fi
exit 0
