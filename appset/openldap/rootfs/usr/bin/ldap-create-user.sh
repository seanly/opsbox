#!/bin/bash

echo -n "Enter User(uid): "
read _ldap_user_uid
echo -n "description: "
read _ldap_user_description
echo -n "givenName: "
read _ldap_user_givenName
echo -n "sn: "
read _ldap_user_sn
echo -n "displayName: "
read _ldap_user_displayName
echo -n "mail: "
read _ldap_user_mail

OPENLDAP_USER_PASSWORD=$(slappasswd -g)
OPENLDAP_USER_PASSWORD_ENC=$(slappasswd -s $OPENLDAP_USER_PASSWORD)
echo ${OPENLDAP_USER_PASSWORD}


USER_LDIF_FILE=/tmp/user.ldif

cat<< EOF > ${USER_LDIF_FILE}
dn: uid=${_ldap_user_uid},ou=users,dc=${OPENLDAP_DOMAIN},${OPENLDAP_SUFFIX}
uid: ${_ldap_user_uid}
description: ${_ldap_user_description}
givenName: ${_ldap_user_givenName}
sn: ${_ldap_user_sn}
cn: ${_ldap_user_uid}
displayName: ${_ldap_user_displayName}
mail: ${_ldap_user_mail}
objectClass: person
objectClass: organizationalPerson
objectClass: inetOrgPerson
userPassword: ${OPENLDAP_USER_PASSWORD_ENC}
EOF

ldapadd -x -D cn=admin,${OPENLDAP_SUFFIX} -w $OPENLDAP_ADMIN_PASSWORD -f ${USER_LDIF_FILE}

echo "${_ldap_user_uid}:${OPENLDAP_USER_PASSWORD}" >> /tmp/ldap-password.txt
