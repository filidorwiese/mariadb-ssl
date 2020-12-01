#!/bin/bash -e

: "${OPENSSL_SUBJECT:="/C=NL/ST=State/L=City/O=Organization/OU=Department/CN=server.fqdn"}"

if [ ! -f /etc/mysql/mariadb.conf.d/55-server-ssl.cnf ]; then

mkdir -p /etc/mysql/ssl
chmod 700 /etc/mysql/ssl
cd /etc/mysql/ssl

openssl genrsa 2048 > ca-key.pem
openssl req -new -x509 -nodes -key ca-key.pem -out ca-cert.pem -subj "$OPENSSL_SUBJECT"
openssl req -newkey rsa:2048 -nodes -keyout server-key.pem -out server-req.pem -subj "$OPENSSL_SUBJECT"
openssl rsa -in server-key.pem -out server-key.pem
openssl x509 -req -in server-req.pem -days 365000 -CA ca-cert.pem -CAkey ca-key.pem -set_serial 01 -out server-cert.pem
chown -R mysql:root /etc/mysql/ssl

cat << EOF > /etc/mysql/mariadb.conf.d/55-server-ssl.cnf
[mysqld]
ssl=on
ssl-ca=/etc/mysql/ssl/ca-cert.pem
ssl-cert=/etc/mysql/ssl/server-cert.pem
ssl-key=/etc/mysql/ssl/server-key.pem
EOF

fi

# Kick off upstream entrypoint
exec /usr/local/bin/docker-entrypoint.sh "$@"
