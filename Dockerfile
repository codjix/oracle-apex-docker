FROM oraclelinux:8-slim

# Set build arguments
ARG ORACLE_DB_VERSION=xe-21c-1.0-1.ol8
ARG ORACLE_ORDS_VERSION=25.3.1.289.1312
ARG ORACLE_APEX_VERSION=24.2

ENV ORACLE_DB_VERSION=${ORACLE_DB_VERSION} \
    ORACLE_ORDS_VERSION=${ORACLE_ORDS_VERSION} \
    ORACLE_APEX_VERSION=${ORACLE_APEX_VERSION}

# Image info
LABEL org.opencontainers.image.title="Oracle Apex" \
    org.opencontainers.image.description="All in one Oracle Apex docker image. Based on OracleLinux with Oracle Database, ORDS and Oracle Apex." \
    org.opencontainers.image.author="Ibrahim Megahed <codjix@gmail.com>" \
    org.opencontainers.image.version="${ORACLE_APEX_VERSION}" \
    oracle.database="${ORACLE_DB_VERSION}" \
    oracle.ords="${ORACLE_ORDS_VERSION}" \
    oracle.apex="${ORACLE_APEX_VERSION}"

# Set environment variables
ENV ORACLE_BASE=/opt/oracle
ENV ORACLE_HOME=${ORACLE_BASE}/product/21c/dbhomeXE
ENV ORACLE_DOCKER_INSTALL=true \
    PATH=$PATH:${ORACLE_HOME}/bin:/opt/ords/bin \
    ORACLE_PDB=XEPDB1 \
    ORACLE_SID=XE \
    # Default credentials
    ORACLE_PWD=Oracle123456 \
    APEX_ADMIN_EMAIL=admin@example.com \
    ORDS_PWD=Oracle123456

# Copy scripts and set permissions
COPY ./scripts/ /opt/scripts/
RUN chmod +x /opt/scripts/*.sh

# Install prerequisites & prepare build directory
WORKDIR /tmp
RUN microdnf download --resolve \
    oracle-database-preinstall-21c java-17-openjdk-headless unzip iproute && \
    microdnf clean all && \
    mkdir -p /build

# Download Oracle software
ADD https://download.oracle.com/otn-pub/otn_software/db-express/oracle-database-${ORACLE_DB_VERSION}.x86_64.rpm /build/database.rpm
ADD https://download.oracle.com/otn_software/java/ords/ords-${ORACLE_ORDS_VERSION}.zip /build/ords.zip
ADD https://download.oracle.com/otn_software/apex/apex_${ORACLE_APEX_VERSION}.zip /build/apex.zip

# Final setup
EXPOSE 1521 8080

CMD [ "/opt/scripts/entrypoint.sh" ]