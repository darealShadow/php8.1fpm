#/bin/bash
ctr=$(buildah from php:8.1-fpm-alpine)
buildah run $ctr apk --no-cache update
buildah run $ctr apk --no-cache upgrade
buildah run $ctr apk --no-cache add libpng libpng-dev zlib-dev libjpeg-turbo freetype libwebp libjpeg-turbo-dev freetype-dev bzip2-dev bzip2 libxslt-dev libmcrypt-dev icu-dev libzip-dev gmp gmp-dev imagemagick-libs imagemagick-dev imagemagick php81-pecl-imagick imap-dev openssl-dev libmemcached php81-pecl-memcache libxml2-dev gettext-dev
buildah run $ctr docker-php-ext-configure gd --enable-gd --with-freetype --with-jpeg
buildah run $ctr docker-php-ext-install gd
buildah run $ctr docker-php-ext-configure imap --with-imap --with-imap-ssl
buildah run $ctr sh -c 'for module in bcmath bz2 calendar exif gettext gmp imap intl mysqli opcache pcntl pdo_mysql shmop sockets soap sysvmsg sysvsem sysvshm zip xsl; \
           do docker-php-ext-configure $module; \
           docker-php-ext-install -j$(nproc) $module; \
        done'
buildah run $ctr apk add autoconf g++ make libmemcached-dev imagemagick-libs imagemagick-dev --virtual .deps1
buildah run $ctr sh -c 'for peclext in apcu imagick igbinary mcrypt memcached memcache msgpack redis; \
           do yes "" | pecl install $peclext; \
           docker-php-ext-enable $peclext; \
           done'

buildah run $ctr apk del .deps1
buildah run $ctr chown -R daemon:daemon /var/www/
buildah config --author "Manuel Eller <manuel.eller@gmx.net>" --label name='php8.1 based on alpine for k8s application' $ctr
buildah config --label source='https://faun.pub/nextcloud-scale-out-using-kubernetes-93c9cac9e493' $ctr
buildah commit $ctr php81fpm
