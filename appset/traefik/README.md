# traefik

## https

le 配置样例

```yaml

version: "3"

services:
  traefik:
    container_name: traefik
    image: "traefik:v2.8.0"
    command:
      - --entrypoints.websecure.address=:443
      - --entrypoints.web.address=:80
      - --providers.docker=true
      - --api
      - --log.level=DEBUG
      - --certificatesresolvers.le.acme.email=seanly@aliyun.com
      - --certificatesresolvers.le.acme.storage=/acme/acme.json
      - --certificatesresolvers.le.acme.dnschallenge=true
      - --certificatesresolvers.le.acme.dnsChallenge.provider=alidns
      - --certificatesresolvers.le.acme.dnsChallenge.delayBeforeCheck=0
      - --certificatesresolvers.le.acme.certificatesDuration=72
      - --certificatesresolvers.le.acme.caServer=https://acme-v02.api.letsencrypt.org/directory
      #- --certificatesresolvers.le.acme.caServer=https://acme-staging-v02.api.letsencrypt.org/directory
    dns:
      - 223.5.5.5
    environment:
      - ALICLOUD_ACCESS_KEY={{AK}}
      - ALICLOUD_SECRET_KEY={{SK}}
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - "/var/run/docker.sock:/var/run/docker.sock:ro"
      - ".data/traefik/acme:/acme"
    labels:
      # Dashboard
      - "traefik.http.routers.traefik.rule=Host(`traefik.opsbox.dev`)"
      - "traefik.http.routers.traefik.service=api@internal"
      - "traefik.http.routers.traefik.middlewares=admin"
      - "traefik.http.routers.traefik.tls=true"
      - "traefik.http.routers.traefik.tls.certResolver=le"
      - "traefik.http.routers.traefik.tls.domains[0].main=opsbox.dev"
      - "traefik.http.routers.traefik.tls.domains[0].sans=*.opsbox.dev"
      - "traefik.http.middlewares.admin.basicauth.users=admin:$$apr1$$J4wW1GaO$$aS0CiGib6UB7FKpvvcfpk0"
      # global redirect to https
      - "traefik.http.middlewares.redirect-to-https.redirectscheme.scheme=https"
      - "traefik.http.routers.redirs.rule=hostregexp(`{host:.+}`)"
      - "traefik.http.routers.redirs.entrypoints=web"
      - "traefik.http.routers.redirs.middlewares=redirect-to-https"

networks:
  default:
    name: opsbox-network
    external: true
```

## admin password

```bash
yum install -y httpd-tools

mkdir -p auth
htpasswd -Bbn admin admin
```

## site config

```yaml

version: "3"

services:
  sample:
    # ...
    labels:
    - "traefik.http.routers.sample.rule=Host(`sample.opsbox.dev`)"
    - "traefik.http.routers.sample.tls=true"
    - "traefik.http.routers.sample.tls.certResolver=le"
```