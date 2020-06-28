#!/bin/bash -e

PHP_MINOR_VERSION=$1

echo "Building layer for PHP 7.$PHP_MINOR_VERSION - using Remi repository"

yum install -y wget yum-utils
wget https://dl.fedoraproject.org/pub/epel/epel-release-latest-6.noarch.rpm
wget https://rpms.remirepo.net/enterprise/remi-release-6.rpm
rpm -Uvh epel-release-latest-6.noarch.rpm
rpm -Uvh remi-release-6.rpm

yum-config-manager --enable remi-php7${PHP_MINOR_VERSION}

yum install -y httpd postgresql-devel libargon2-devel compat-libtiff3 libXpm

yum install -y --disablerepo="amzn-main" --enablerepo="epel" libwebp

yum install -y --disablerepo="*" --enablerepo="remi,remi-php7${PHP_MINOR_VERSION}" php php-mbstring php-pdo php-mysql php-pgsql php-xml php-process php-opcache php-dom php-gd php-zip

mkdir /tmp/layer
cd /tmp/layer
cp /opt/layer/bootstrap bootstrap
sed "s/PHP_MINOR_VERSION/${PHP_MINOR_VERSION}/g" /opt/layer/php.ini >php.ini

mkdir bin
cp /usr/bin/php bin/

mkdir lib
for lib in libncurses.so.5 libtinfo.so.5 libpcre.so.0; do
  cp "/lib64/${lib}" lib/
done

for lib in libedit.so.0 libargon2.so.0 libpq.so.5 libonig.so.105 libtiff.so.3 libXpm.so.4 libwebp.so.5 libzip.so.5 libgd.so.3; do
  cp "/usr/lib64/${lib}" lib/
done

mkdir -p lib/php/7.${PHP_MINOR_VERSION}
cp -a /usr/lib64/php/modules lib/php/7.${PHP_MINOR_VERSION}/

zip -r /opt/layer/php7${PHP_MINOR_VERSION}.zip .
