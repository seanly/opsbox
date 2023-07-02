ARG KEYCLOAK_VERSION=14.0.0
FROM quay.io/keycloak/keycloak:${KEYCLOAK_VERSION}

RUN cd  /opt/jboss/keycloak/standalone/deployments/; \
    curl -sLfO https://github.com/jacekkow/keycloak-protocol-cas/releases/download/${KEYCLOAK_VERSION}/keycloak-protocol-cas-${KEYCLOAK_VERSION}.jar 