#!/bin/bash
apt-get install make gcc
cd /home/
wget https://www.haproxy.org/download/1.7/src/haproxy-1.7.8.tar.gz
tar -zxvf haproxy-1.7.8.tar.gz
cd haproxy-1.7.8
make TARGET=linux4908 PREFIX=/home/haproxy
make install PREFIX=/home/haproxy
