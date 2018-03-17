#!/bin/bash

function grant() {
  grant all privileges on *.* to 'root'@'%'identified by 'passwd' with grant option;
  ALL PRIVILEGES;
}

function install() {
	yum -y install mariadb mariadb-server
	systemctl start mariadb
	systemctl enable mariadb
}
