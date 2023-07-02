#!/bin/bash

echo -n "Enter Group Name(cn): "
read _ldap_group_cn

_ldap_group_member_list=()
while IFS= read -r -p "Member item (end with an empty line): " line; do
    [[ $line ]] || break  # break if line is empty
    _ldap_group_member_list+=("$line")
done

GROUP_LDIF_FILE=/tmp/group.ldif

cat<< EOF > ${GROUP_LDIF_FILE}
dn: cn=${_ldap_group_cn},ou=groups,dc=${OPENLDAP_DOMAIN},${OPENLDAP_SUFFIX}
cn: ${_ldap_group_cn}
objectClass: groupOfNames
member: cn=_dummy
EOF

for _member in ${_ldap_group_member_list[@]}
do
  echo "member: uid=${_member},ou=users,dc=${OPENLDAP_DOMAIN},${OPENLDAP_SUFFIX}" >> ${GROUP_LDIF_FILE}
done

ldapadd -x -D cn=admin,${OPENLDAP_SUFFIX} -w $OPENLDAP_ADMIN_PASSWORD -f ${GROUP_LDIF_FILE}
