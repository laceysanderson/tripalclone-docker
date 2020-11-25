FROM laceysanderson/drupal7dev

MAINTAINER Lacey-Anne Sanderson <laceyannesanderson@gmail.com>

USER root

COPY . /app

## Copy the files for the existing website into the correct directories.
WORKDIR /var/www/html/sites/all
RUN rm -R modules && rm -R libraries && rm -R themes \
	&& mv /app/alldir.tar.gz ./ \
	&& tar zxvf alldir.tar.gz \
	&& cd /var/www/html/sites/default \
	&& mv /app/filesdir.tar.gz ./ \
	&& tar zxvf filesdir.tar.gz

## Expand the database dump after creating the database.
WORKDIR /app
RUN service postgresql start \
	&& PGPASSWORD=docker psql --user docker --command "CREATE ROLE tripaladmin WITH PASSWORD '$DBPASS'" \
	&& PGPASSWORD=docker psql --user docker --command "ALTER ROLE tripaladmin WITH LOGIN" \
	&& PGPASSWORD=docker psql --user docker --command "CREATE DATABASE tripaldb WITH OWNER tripaladmin" \
	&& PGPASSWORD=docker pg_restore --dbname=tripaldb --username=tripaladmin database.pgdump

## Ensure the settings.php matches the database.
WORKDIR /var/www/html/sites/default/
RUN cp /app/default_files/settings.php settings.php \
	&& sed -i "s/'password' => 'somesecurepassword',/'password' => '$DBPASS',/g" settings.php

WORKDIR /var/www/html
