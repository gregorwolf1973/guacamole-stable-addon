#!/usr/bin/env bash
set -e

CONFIG_PATH=/data/options.json

# Read config options (with defaults if running outside HA)
if [ -f "${CONFIG_PATH}" ]; then
    LOG_LEVEL=$(jq -r '.log_level // "info"' ${CONFIG_PATH})
    GUACADMIN_PASSWORD=$(jq -r '.guacadmin_password // "guacadmin"' ${CONFIG_PATH})
else
    LOG_LEVEL="info"
    GUACADMIN_PASSWORD="guacadmin"
fi

echo "============================================================"
echo "  Guacamole Stable - Apache Guacamole 1.5.5 + FreeRDP 2.11"
echo "============================================================"
echo "  Log level: ${LOG_LEVEL}"
echo "  Architecture: $(uname -m)"
echo "============================================================"

# -----------------------------------------------------------------------------
# 1. Initialize PostgreSQL on first run
# -----------------------------------------------------------------------------
if [ ! -s "${PGDATA}/PG_VERSION" ]; then
    echo "[init] First run: initializing PostgreSQL data directory at ${PGDATA}"
    mkdir -p "${PGDATA}"
    chown -R postgres:postgres "${PGDATA}"
    chmod 700 "${PGDATA}"
    sudo -u postgres /usr/lib/postgresql/14/bin/initdb -D "${PGDATA}" \
        --auth-local=trust --auth-host=md5 --encoding=UTF8

    cat >> "${PGDATA}/postgresql.conf" <<EOF
listen_addresses = 'localhost'
port = 5432
unix_socket_directories = '/tmp'
EOF
    NEEDS_DB_SETUP=1
else
    echo "[init] Existing PostgreSQL data found at ${PGDATA}"
    NEEDS_DB_SETUP=0
fi

# -----------------------------------------------------------------------------
# 2. Start PostgreSQL
# -----------------------------------------------------------------------------
echo "[postgres] Starting PostgreSQL..."
sudo -u postgres /usr/lib/postgresql/14/bin/pg_ctl -D "${PGDATA}" \
    -l /tmp/postgres.log -w start

# Wait for PostgreSQL
for i in $(seq 1 30); do
    if sudo -u postgres psql -h /tmp -c "SELECT 1" >/dev/null 2>&1; then
        echo "[postgres] Ready"
        break
    fi
    sleep 1
done

# -----------------------------------------------------------------------------
# 3. Setup Guacamole DB on first run
# -----------------------------------------------------------------------------
if [ "${NEEDS_DB_SETUP}" = "1" ]; then
    echo "[init] Creating Guacamole database and user..."
    sudo -u postgres psql -h /tmp <<-EOSQL
        CREATE DATABASE guacamole_db;
        CREATE USER guacamole_user WITH ENCRYPTED PASSWORD 'guacamole_pass';
        GRANT ALL PRIVILEGES ON DATABASE guacamole_db TO guacamole_user;
EOSQL

    echo "[init] Applying Guacamole schema..."
    cat /opt/guacamole-schema/*.sql | sudo -u postgres psql -h /tmp -d guacamole_db
    sudo -u postgres psql -h /tmp -d guacamole_db -c \
        "GRANT ALL ON ALL TABLES IN SCHEMA public TO guacamole_user;"
    sudo -u postgres psql -h /tmp -d guacamole_db -c \
        "GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO guacamole_user;"

    if [ "${GUACADMIN_PASSWORD}" != "guacadmin" ]; then
        echo "[init] Setting custom guacadmin password..."
        SALT_HEX=$(openssl rand -hex 32 | tr '[:lower:]' '[:upper:]')
        HASH_HEX=$(printf '%s' "${GUACADMIN_PASSWORD}${SALT_HEX}" \
            | sha256sum | awk '{print $1}' | tr '[:lower:]' '[:upper:]')

        sudo -u postgres psql -h /tmp -d guacamole_db <<-EOSQL
            UPDATE guacamole_user 
            SET password_hash = decode('${HASH_HEX}', 'hex'),
                password_salt = decode('${SALT_HEX}', 'hex'),
                password_date = CURRENT_TIMESTAMP
            WHERE entity_id = (
                SELECT entity_id FROM guacamole_entity 
                WHERE name = 'guacadmin' AND type = 'USER'
            );
EOSQL
    fi
    echo "[init] Database setup complete."
fi

# -----------------------------------------------------------------------------
# 4. Generate guacamole.properties
# -----------------------------------------------------------------------------
echo "[config] Writing guacamole.properties..."
cat > /etc/guacamole/guacamole.properties <<EOF
# guacd
guacd-hostname: localhost
guacd-port: 4822

# PostgreSQL JDBC
postgresql-hostname: localhost
postgresql-port: 5432
postgresql-database: guacamole_db
postgresql-username: guacamole_user
postgresql-password: guacamole_pass
postgresql-auto-create-accounts: false
EOF

# -----------------------------------------------------------------------------
# 5. Start guacd in background
# -----------------------------------------------------------------------------
echo "[guacd] Starting guacd 1.5.5 with FreeRDP 2.11..."
LD_LIBRARY_PATH=/opt/freerdp/lib:/opt/guacamole/lib \
    /opt/guacamole/sbin/guacd -b 127.0.0.1 -L "${LOG_LEVEL}" -f &
GUACD_PID=$!

# Wait for guacd
for i in $(seq 1 15); do
    if nc -z 127.0.0.1 4822 2>/dev/null; then
        echo "[guacd] Ready on port 4822 (PID ${GUACD_PID})"
        break
    fi
    sleep 1
done

# -----------------------------------------------------------------------------
# 6. Graceful shutdown handler
# -----------------------------------------------------------------------------
shutdown_handler() {
    echo "[shutdown] Stopping services..."
    "${CATALINA_HOME}/bin/catalina.sh" stop 2>/dev/null || true
    kill "${GUACD_PID}" 2>/dev/null || true
    sudo -u postgres /usr/lib/postgresql/14/bin/pg_ctl -D "${PGDATA}" -m fast stop || true
    exit 0
}
trap shutdown_handler SIGTERM SIGINT

# -----------------------------------------------------------------------------
# 7. Start Tomcat (foreground)
# -----------------------------------------------------------------------------
echo "[tomcat] Starting Tomcat with Guacamole webapp..."
export JAVA_OPTS="-Xms256m -Xmx512m"
export GUACAMOLE_HOME=/etc/guacamole

exec "${CATALINA_HOME}/bin/catalina.sh" run
