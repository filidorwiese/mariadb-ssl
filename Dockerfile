FROM mariadb:10.5

ARG OPENSSL_SUBJECT="/C=NL/ST=State/L=City/O=Organization/OU=Department/CN=server.fqdn"

RUN apt-get update && apt-get install -y --no-install-recommends \
    openssl

RUN mkdir -p /etc/mysql/ssl && \
    chmod 700 /etc/mysql/ssl && \
    cd /etc/mysql/ssl && \
    openssl genrsa 2048 > ca-key.pem && \
    openssl req -new -x509 -nodes -days 365000 -key ca-key.pem -out ca-cert.pem -subj "$OPENSSL_SUBJECT" && \
    openssl req -newkey rsa:2048 -days 365000 -nodes -keyout server-key.pem -out server-req.pem -subj "$OPENSSL_SUBJECT" && \
    openssl rsa -in server-key.pem -out server-key.pem && \
    openssl x509 -req -in server-req.pem -days 365000 -CA ca-cert.pem -CAkey ca-key.pem -set_serial 01 -out server-cert.pem && \
    chown -R mysql:root /etc/mysql/ssl

RUN printf '[mysqld]\n\
ssl=on\n\
ssl-ca=/etc/mysql/ssl/ca-cert.pem\n\
ssl-cert=/etc/mysql/ssl/server-cert.pem\n\
ssl-key=/etc/mysql/ssl/server-key.pem\n'\
> /etc/mysql/mariadb.conf.d/55-server-ssl.cnf

