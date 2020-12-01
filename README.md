### MariaDB with ssl

This wraps the official [MariaDB 10.5](https://hub.docker.com/_/mariadb) docker image with a script to generate self-signed certificates on initial startup.

You can specify the openssl request subject with the `OPENSSL_SUBJECT` environment variable to tweak the certificates:

```
docker run -e MYSQL_ROOT_PASSWORD=12345 -e OPENSSL_SUBJECT="/C=US/ST=State/L=City/O=Organization/OU=Department/CN=server.fqdn" -it mariadb-ssl mysqld
```

Note that this only has effect on the first run of the image, when the certificates are created. 
