FROM mariadb:10.3

RUN apt-get update && apt-get install -y --no-install-recommends \
    openssl

COPY generate-ssl-certs.sh /usr/local/bin/
ENTRYPOINT ["generate-ssl-certs.sh"]

CMD ["mysqld"]
