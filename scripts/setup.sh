#!/bin/bash
set -e

if [ ! -f /opt/.software-install ]; then
    # ========= Post-installation stage =========
    echo "🚀 Starting Oracle APEX Docker container setup..."
    echo "📦 Installing dependencies..."
    rpm -ivh /tmp/*.rpm
    rm -f /tmp/*.rpm
    echo "✅ Dependencies installed."

    echo "🗄️  Setting up Oracle Database XE..."
    chown -R oracle:oinstall $ORACLE_BASE
    rpm -ivh /build/database.rpm
    echo "✅ Oracle Database XE installed."

    echo "📂 Extracting APEX and ORDS..."
    unzip /build/apex.zip -d $ORACLE_BASE/
    unzip /build/ords.zip -d /opt/ords/
    chown -R oracle:oinstall $ORACLE_BASE/apex /opt/ords
    echo "✅ APEX and ORDS extracted."

    touch /opt/.software-install
else
    echo "💾 Software already installed, skipping installation."
fi

if [ ! -f $ORACLE_BASE/oradata/.software-setup ]; then
    # ======== Database & APEX Setup =========
    echo "🔧 Configuring Oracle Database XE..."
    echo "🆕 First-time database configuration..."
    (echo "$ORACLE_PWD"; echo "$ORACLE_PWD") | /etc/init.d/oracle-xe-21c configure

    echo "🧩 Installing APEX..."
    cd $ORACLE_BASE/apex
    sqlplus -s sys/${ORACLE_PWD}@//localhost:1521/${ORACLE_PDB} as sysdba <<EOF
@apexins.sql SYSAUX SYSAUX TEMP /i/
@apex_rest_config.sql ${ORDS_PWD} ${ORDS_PWD}
ALTER USER APEX_PUBLIC_USER IDENTIFIED BY ${ORDS_PWD} ACCOUNT UNLOCK;
ALTER USER APEX_REST_PUBLIC_USER IDENTIFIED BY ${ORDS_PWD} ACCOUNT UNLOCK;
ALTER USER APEX_LISTENER IDENTIFIED BY ${ORDS_PWD} ACCOUNT UNLOCK;
BEGIN
    APEX_UTIL.set_security_group_id(10);
    APEX_UTIL.create_user(
        p_user_name       => 'ADMIN',
        p_email_address   => '${APEX_ADMIN_EMAIL}',
        p_web_password    => '${ORACLE_PWD}',
        p_developer_privs => 'ADMIN',
        p_change_password_on_first_use => 'N'
    );
    APEX_UTIL.set_security_group_id(null);
    COMMIT;
END;
/
EXIT;
EOF
    cd -

    # ======= ORDS Setup ========
    echo "⚙️  Installing ORDS..."
    cd /opt/ords
    ords --config $ORACLE_BASE/oradata/ords-config install \
        --admin-user SYS \
        --db-hostname localhost \
        --db-port 1521 \
        --db-servicename ${ORACLE_PDB} \
        --db-user ORDS_PUBLIC_USER \
        --feature-db-api true \
        --feature-rest-enabled-sql true \
        --feature-sdw true \
        --gateway-mode proxied \
        --gateway-user APEX_PUBLIC_USER \
        --proxy-user \
        --password-stdin <<EOF
${ORACLE_PWD}
${ORDS_PWD}
${ORDS_PWD}
EOF
    echo "🔒 Setting ORDS static path..."
    ords --config $ORACLE_BASE/oradata/ords-config config set standalone.static.path $ORACLE_BASE/apex/images
    touch $ORACLE_BASE/oradata/.software-setup
    cd -

    echo "✅ Database & APEX Setup complete."
else
    echo "💾 Existing database found, skipping setup."
fi
