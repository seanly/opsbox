#!/bin/bash

set -ex

# Changing the open file descriptors limit, otherwise slapd memory
# consumption is crazy
# https://github.com/moby/moby/issues/8231
ulimit -n 1024

FIRST_START_DONE=/slapd-first-start-done
OPENLDAP_LDIF_DIR=/srv/openldap/ldif.d

# container first start
if [ ! -e "$FIRST_START_DONE" ]; then

  if [ ! -f /data/lib/ldap/DB_CONFIG ]; then
      if [ -z "$OPENLDAP_ADMIN_PASSWORD" -o -z "$OPENLDAP_CONFIG_PASSWORD" ]; then
          echo "Need OPENLDAP_ADMIN_PASSWORD and OPENLDAP_CONFIG_PASSWORD"
          exit
      fi

      cp /usr/share/openldap-servers/DB_CONFIG.example /var/lib/ldap/DB_CONFIG
      chown ldap. /var/lib/ldap/DB_CONFIG

      OPENLDAP_CONFIG_PASSWORD_ENC=$(slappasswd -s $OPENLDAP_CONFIG_PASSWORD)
      export OPENLDAP_CONFIG_PASSWORD_ENC
      OPENLDAP_ADMIN_PASSWORD_ENC=$(slappasswd -s $OPENLDAP_ADMIN_PASSWORD)
      export OPENLDAP_ADMIN_PASSWORD_ENC

      cat /etc/openldap/slapd.ldif.tpl | envsubst > /etc/openldap/slapd.ldif
      rm -rf /etc/openldap/slapd.d/*
      slapadd -v -F /etc/openldap/slapd.d -n 0 -l /etc/openldap/slapd.ldif
      chown -R ldap:ldap /etc/openldap/slapd.d

      /usr/sbin/slapd -h "ldap:/// ldaps:/// ldapi:///" -u ldap -d $DEBUG_LEVEL &
      slapd_pid=$!
      sleep 3

      cat ${OPENLDAP_LDIF_DIR}/001-domain.ldif | envsubst > /tmp/domain.ldif
      cat ${OPENLDAP_LDIF_DIR}/002-structure.ldif | envsubst > /tmp/structure.ldif

      export OPENLDAP_LDAPADMIN_PASSWORD=${OPENLDAP_LDAPADMIN_PASSWORD:-ldapadmin}
      cat ${OPENLDAP_LDIF_DIR}/003-ldapadmin.ldif | envsubst > /tmp/ldapadmin.ldif
      ldapadd -x -D cn=admin,${OPENLDAP_SUFFIX} -w $OPENLDAP_ADMIN_PASSWORD -f /tmp/domain.ldif
      ldapadd -x -D cn=admin,${OPENLDAP_SUFFIX} -w $OPENLDAP_ADMIN_PASSWORD -f /tmp/structure.ldif
      ldapadd -x -D cn=admin,${OPENLDAP_SUFFIX} -w $OPENLDAP_ADMIN_PASSWORD -f /tmp/ldapadmin.ldif

      kill "$slapd_pid"
      wait "$slapd_pid"

      mkdir /data/lib /data/etc
      cp -ar /var/lib/ldap /data/lib
      cp -ar /etc/openldap /data/etc
  fi


  rm -rf /var/lib/ldap && ln -s /data/lib/ldap /var/lib/ldap
  rm -rf /etc/openldap && ln -s /data/etc/openldap /etc/openldap

  pushd /var/lib/ldap
  db_recover -v -h .
  db_upgrade -v -h . *.bdb
  db_checkpoint -v -h . -1
  chown -R ldap: .
  popd
  touch $FIRST_START_DONE
fi

exec /usr/sbin/slapd -h "ldap:/// ldaps:/// ldapi:///" -u ldap -d $DEBUG_LEVEL
