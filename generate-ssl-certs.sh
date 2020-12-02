#!/bin/bash -e

: "${OPENSSL_SERVER_SUBJECT:="/C=NL/ST=State/L=City/O=Organization/OU=Department/CN=server.fqdn"}"
: "${OPENSSL_CLIENT_SUBJECT:="/C=NL/ST=State/L=City/O=Organization/OU=Department/CN=client.fqdn"}"
: "${OPENSSL_CA_SUBJECT:="/C=NL/ST=State/L=City/O=Organization/OU=Department/CN=ca.fqdn"}"
: "${EXPIRE_DAYS:=3650}"

DIR=/etc/mysql/ssl
CONF_FILE="/etc/mysql/mariadb.conf.d/55-server-ssl.cnf"

if [ ! -f "${CONF_FILE}" ]; then

mkdir -p "${DIR}"
chmod 700 "${DIR}"
cd "${DIR}"

# Create CA certificate
openssl genrsa 2048 > ca-key.pem
openssl req -new -x509 -nodes -days ${EXPIRE_DAYS} \
        -key ca-key.pem -subj "${OPENSSL_CA_SUBJECT}" \
        -out ca.pem

# Create server certificate, remove passphrase, and sign it
# server-cert.pem = public key, server-key.pem = private key
openssl req -newkey rsa:2048 -days ${EXPIRE_DAYS} \
        -nodes -keyout server-key.pem -subj "${OPENSSL_SERVER_SUBJECT}" \
        -out server-req.pem
openssl rsa -in server-key.pem -out server-key.pem
openssl x509 -req -in server-req.pem -days ${EXPIRE_DAYS} \
        -CA ca.pem -CAkey ca-key.pem -set_serial 01 \
        -out server-cert.pem

# Create client certificate, remove passphrase, and sign it
# client-cert.pem = public key, client-key.pem = private key
openssl req -newkey rsa:2048 -days 3600 \
        -nodes -keyout client-key.pem -subj "${OPENSSL_SERVER_SUBJECT}" \
        -out client-req.pem
openssl rsa -in client-key.pem -out client-key.pem
openssl x509 -req -in client-req.pem -days 3600 \
        -CA ca.pem -CAkey ca-key.pem -set_serial 01 -out client-cert.pem

openssl verify -CAfile ca.pem server-cert.pem client-cert.pem

chown -R mysql:root "${DIR}"

cat << EOF > "${CONF_FILE}"
[client]
ssl-ca=${DIR}/ca.pem
ssl-cert=${DIR}/client-cert.pem
ssl-key=${DIR}/client-key.pem

[mysqld]
ssl=on
ssl_ca=${DIR}/ca.pem
ssl_cert=${DIR}/server-cert.pem
ssl_key=${DIR}/server-key.pem
EOF

fi

# Kick off upstream entrypoint
exec /usr/local/bin/docker-entrypoint.sh "$@"
