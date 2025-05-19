FROM python:3.12-slim-bookworm

ARG CORE_TAG=v2.5.9
ARG MODULES_TAG=v3.0.2

ENV DEBIAN_FRONTEND=noninteractive
ENV DEBIAN_PRIORITY=critical

RUN apt-get update; apt-get install -y --no-install-recommends \
        ca-certificates curl git gettext procps sudo nginx rsync jq \
	supervisor cron openssl gpg gpg-agent rsyslog zip unzip \
        postfix redis-server mariadb-client mariadb-server sqlite3 \
	iproute2 net-tools iputils-ping socat \
	php8.2 php8.2-apcu php8.2-curl php8.2-xml php8.2-intl php8.2-bcmath \
        php8.2-mbstring php8.2-mysql php8.2-redis php8.2-gd php8.2-fpm \
	php8.2-zip php8.2-ldap libmagic1 libldap-common librdkafka1 \
        libbrotli1 libsimdjson14 libzstd1 ssdeep libfuzzy2 \
	libpoppler-cpp-dev libzbar0 tesseract-ocr \
 && sed -i '/imklog/s/^/#/' /etc/rsyslog.conf \
 && update-alternatives --set php /usr/bin/php8.2 \
 && apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/*

# Python dependencies and misp-modules
RUN apt-get update && apt-get install -y --no-install-recommends g++ \
 && pip install misp-modules[all] \
 && apt-get purge -y g++ \
 && apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/*

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# MISP Core
RUN <<-EOF
	git clone --branch ${CORE_TAG} --depth 1 https://github.com/MISP/MISP.git /var/www/MISP
	cd /var/www/MISP
	git submodule update --init --recursive .
	pip3 install -r requirements.txt
	cd app
	composer config --no-interaction allow-plugins.composer/installers true
	composer install
	composer require --with-all-dependencies --no-interaction \
		elasticsearch/elasticsearch:^8.7.0 \
		jakub-onderka/openid-connect-php:^1.0.0 \
		aws/aws-sdk-php

	# nginx config
	rm /etc/nginx/sites-enabled/*
	mkdir -p /run/php /etc/nginx/certs

        # Remove files we do not care for
        find /var/www/MISP/INSTALL/* ! -name 'MYSQL.sql' -type f -exec rm {} +
        find /var/www/MISP/INSTALL/* ! -name 'MYSQL.sql' -type l -exec rm {} +
        # Remove most files in .git - we do not use git functionality in docker
        find /var/www/MISP/.git/* ! -name HEAD -exec rm -rf {} +
        # Remove libraries submodules
        rm -r /var/www/MISP/PyMISP
        rm -r /var/www/MISP/app/files/scripts/cti-python-stix2
        rm -r /var/www/MISP/app/files/scripts/misp-stix
        rm -r /var/www/MISP/app/files/scripts/mixbox
        rm -r /var/www/MISP/app/files/scripts/python-cybox
        rm -r /var/www/MISP/app/files/scripts/python-maec
        rm -r /var/www/MISP/app/files/scripts/python-stix

	# Make a copy of the file and configuration stores, so we can sync from it
        cp -R /var/www/MISP/app/files /var/www/MISP/app/files.dist
        echo "${CORE_TAG}" > /var/www/MISP/app/files/VERSION
        cp -R /var/www/MISP/app/Config /var/www/MISP/app/Config.dist
        find /var/www/MISP \( ! -user www-data -or ! -group www-data \) -exec chown www-data:www-data '{}' +;
        find /var/www/MISP -not -perm 550 -type f -exec chmod 0550 '{}' +;
        find /var/www/MISP -not -perm 770 -type d -exec chmod 0770 '{}' +;
        # Diagnostics wants this file to be present and writable even if we do not use git in docker land
        touch /var/www/MISP/.git/ORIG_HEAD && chmod 0600 /var/www/MISP/.git/ORIG_HEAD && chown www-data:www-data /var/www/MISP/.git/ORIG_HEAD
EOF

COPY files/ /

COPY scripts/ /opt/scripts-hackinsdn/

WORKDIR /var/www/MISP

EXPOSE 80 443

ENTRYPOINT [ "/entrypoint.sh" ]
