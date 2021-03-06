#!/bin/bash

php_install_dir="/home/php7"
php_url="http://cn2.php.net/distributions/php-7.2.2.tar.gz"
php_fpm_service="https://raw.githubusercontent.com/yh147/dotfiles/master/service/php-fpm.service"

function install_php() {
	add_user
	check_dependence
	download_src
	config_php
	clear_src
}

function check_dependence() {
	version=`cat /proc/version`
	if [[ $version =~ "centos" ]]; then
		yum install -y gcc
		yum install -y wget
		yum install -y openssl openssl-devel
		yum install -y libxml2
		yum install -y libxml2-devel
		yum install -y curl-devel
		yum install -y libpng
		yum install -y libpng-devel
		yum install -y freetype-devel
	elif [[ $version =~ "debian" ]]; then
		apt-get install -y gcc
		apt-get install -y make
		apt-get install -y libxml2-dev
		apt-get install -y openssl libssl-dev
		apt-get install -y libpng-dev
		apt-get install -y libfreetype6-dev
		apt-get install -y libmcrypt-dev
		apt-get install -y curl
                apt-get install -y libcurl4-gnutls-dev
                ln -s /usr/include/x86_64-linux-gnu/curl /usr/include/
		ln -s /usr/lib/x86_64-linux-gnu/libssl.so  /usr/lib
	fi
}

function add_user() {
	groupadd -r php
	useradd -r -g php -s /bin/false -M php
}

function download_src() {
	cd /home
	wget $php_url
}

function config_php() {
	tar -zxvf php-7.2.2.tar.gz && \
	cd php-7.2.2 && \
	./configure  --prefix=$php_install_dir \
	--with-gd \
	--with-zlib \
	--with-curl \
	--with-freetype-dir \
	--enable-gd-native-ttf \
	--enable-mysqlnd \
	--with-pdo-mysql=mysqlnd \
	--with-mysql \
	--with-mysqli \
	--with-openssl \
	--with-mcrypt \
	--enable-mbstring \
	--enable-zip \
	--enable-fpm \
	--with-fpm-user=php \
	--with-fpm-group=php &&\
	make && make install
	cp php.ini-production $php_install_dir/lib/php.ini
	cp $php_install_dir/etc/php-fpm.conf.default $php_install_dir/etc/php-fpm.conf
	cp $php_install_dir/etc/php-fpm.d/www.conf.default $php_install_dir/etc/php-fpm.d/www.conf
}

function clear_src() {
	rm -rf /home/php-*
}

function start_php() {
	systemctl start php-fpm
}

function stop_php() {
	systemctl stop php-fpm
}

function uninstall_php() {
	stop_php
	systemctl disable php-fpm
	rm -rf /etc/systemd/system/php-fpm.service
	rm -rf $php_install_dir
}

function init_php() {
	wget -P /etc/systemd/system/ $php_fpm_service
	systemctl start php-fpm
	systemctl enable php-fpm
	systemctl status php-fpm
}

case $1 in
	install)
		echo "start install php"
		install_php
		init_php
		;;
	uninstall)
		echo "uninstall php"
		uninstall_php
		;;
	start)
		echo "start php"
		start_php
		;;
	stop)
		echo "stop php"
		stop_php
		;;
	*)
		echo $"Usage: $0 {start|stop|install|uninstall}"
		;;
esac
