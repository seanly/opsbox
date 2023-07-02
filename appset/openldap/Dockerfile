FROM seanly/toolset:envsubst as envsubst

FROM centos:7

# Add locales
RUN set -o errexit -o nounset \
  && echo 'LANG=en_GB.UTF-8' > /etc/locale.conf \
  && echo 'LC_ALL=en_GB.UTF-8' >> /etc/locale.conf \
  && echo 'LANGUAGE=en_GB:en' >> /etc/locale.conf \
  && /bin/cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

ENV LANG=en_GB.UTF-8
ENV LANGUAGE=en_GB.UTF-8
ENV LC_ALL=en_GB.UTF-8
ENV TZ=Asia/Chongqing

RUN sed -i '/^override_install_langs=/d' /etc/yum.conf \
  && yum install -y --nogpgcheck epel-release && yum makecache \
  && yum install -y --nogpgcheck unzip zip python-pip jq \
        openldap compat-openldap openldap-clients \
        openldap-servers openldap-servers-sql openldap-devel \
  && rm -r /var/cache/yum

COPY --from=envsubst /usr/bin/envsubst /usr/bin/

# See possible debug levels in man page (loglevel): http://linux.die.net/man/5/slapd.conf
ENV DEBUG_LEVEL=256

EXPOSE 389

VOLUME [ "/data" ]

COPY ./rootfs/ /

ENTRYPOINT ["/entrypoint.sh"]

