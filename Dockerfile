FROM php:7-apache

MAINTAINER Tomohito Inoue <hypernumbernet@users.noreply.github.com>

RUN a2enmod rewrite

RUN set -xe \
    && apt-get update \
    && apt-get install -y curl unzip bzip2 libpq-dev libpng-dev libjpeg-dev \
    && rm -rf /var/lib/apt/lists/* \
    && docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr \
    && docker-php-ext-install gd mysqli pgsql

WORKDIR /var/www/html

ENV PHPBB_VERSION 3.2.2
ENV PHPBB_URL https://www.phpbb.com/files/release/phpBB-${PHPBB_VERSION}.tar.bz2
ENV PHPBB_SHA bab64dbd79f6f1bf2c0c306b33cea460ffe58c56ff1e81aac87ee10545291302
ENV PHPBB_FILE phpBB.tar.bz2

RUN set -xe \
    && curl -fSL ${PHPBB_URL} -o ${PHPBB_FILE} \
    && echo "${PHPBB_SHA}  ${PHPBB_FILE}" | sha256sum -c - \
    && tar -xjf ${PHPBB_FILE} --strip-components=1 \
    && rm ${PHPBB_FILE}

ENV PHPBB_LANG_URL 'https://www.phpbb.com/customise/db/download/92251'
ENV PHPBB_LANG_FILE 'japanese_1_0_5.zip'
ENV PHPBB_LANG_SHA256 'b23e817714dbe418cf39db91507401e3ae2fcc204035612f9659b89160374e3f'
ENV PHPBB_LANG_DIR 'japanese_1_0_5'

WORKDIR /tmp

RUN curl -SL ${PHPBB_LANG_URL} -o ${PHPBB_LANG_FILE} \
    && echo "${PHPBB_LANG_SHA256}  ${PHPBB_LANG_FILE}" | sha256sum -c - \
    && unzip ${PHPBB_LANG_FILE} \
    && cp -pr ${PHPBB_LANG_DIR}/* /var/www/html \
    && rm -r ${PHPBB_LANG_DIR} \
    && rm -f ${PHPBB_LANG_FILE}

WORKDIR /var/www/html

RUN chown -R www-data:www-data .
