### MariaDB with ssl

This wraps the official [MariaDB 10.5](https://hub.docker.com/_/mariadb) docker image with a script to generate self-signed certificates on initial startup.

You can specify the openssl request subject (such as the Common Name) with the `OPENSSL_SERVER_SUBJECT` environment variable to tweak the certificates:

```
docker run -e MYSQL_ROOT_PASSWORD=12345 -e OPENSSL_SERVER_SUBJECT="/C=US/ST=State/L=City/O=Organization/OU=Department/CN=server.fqdn" -it mariadb-ssl
```

Likewise `OPENSSL_CA_SUBJECT` and `OPENSSL_CLIENT_SUBJECT` can be defined if needed, but they are all optional.

Note that this only has effect on the first run of the image, when the certificates are created. 


## Test

Exec the docker container and log into the mysql server:
```
$ mysql --ssl -u root -p
```

Then run this SQL statement to verify SSL is enabled on the server:
```
MariaDB [(none)]> SHOW VARIABLES LIKE '%ssl%';
+---------------------+--------------------------------+
| Variable_name       | Value                          |
+---------------------+--------------------------------+
| have_openssl        | YES                            |
| have_ssl            | YES                            |
| ssl_ca              | /etc/mysql/ssl/ca-cert.pem     |
| ssl_capath          |                                |
| ssl_cert            | /etc/mysql/ssl/server-cert.pem |
| ssl_cipher          |                                |
| ssl_crl             |                                |
| ssl_crlpath         |                                |
| ssl_key             | /etc/mysql/ssl/server-key.pem  |
| version_ssl_library | OpenSSL 1.1.1f  31 Mar 2020    |
+---------------------+--------------------------------+
```

And to verify your current connection is using SSL:
```
MariaDB [(none)]> SHOW STATUS LIKE 'Ssl_cipher';
+---------------+------------------------+
| Variable_name | Value                  |
+---------------+------------------------+
| Ssl_cipher    | TLS_AES_256_GCM_SHA384 |
+---------------+------------------------+
```

