
#user  nobody;
worker_processes  1;

#error_log  logs/error.log;
#error_log  logs/error.log  notice;
#error_log  logs/error.log  info;

#pid        logs/nginx.pid;


events {
    worker_connections  1024;
}


http {
    include       mime.types;
    default_type  application/octet-stream;

    #log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
    #                  '$status $body_bytes_sent "$http_referer" '
    #                  '"$http_user_agent" "$http_x_forwarded_for"';

    #access_log  logs/access.log  main;

    sendfile        on;
    #tcp_nopush     on;

    #keepalive_timeout  0;
    keepalive_timeout  65;

    #gzip  on;

    server {
        listen 443 ssl;
        server_name  www.yanjie.com yanjie.com;
		ssl_certificate /etc/letsencrypt/live/www.yanjie.com/fullchain.pem;
		ssl_certificate_key /etc/letsencrypt/live/www.yanjie.com/privkey.pem;
        #charset koi8-r;

        #access_log  logs/host.access.log  main;

        location / {
            root   /home/sites/bbs;
            index  index.php index.html index.htm;
        }

        #error_page  404              /404.html;

        # redirect server error pages to the static page /50x.html
        #
        error_page   500 502 503 504  /50x.html;
        location = /50x.html {
            root   html;
        }

   
        location ~ \.php$ {
            root           /home/sites/bbs;
            fastcgi_pass   127.0.0.1:9000;
            fastcgi_index  index.php;
            fastcgi_param  SCRIPT_FILENAME  /home/sites/bbs/$fastcgi_script_name;
            include        fastcgi_params;
        }

    }

	server {
		listen 80;
		server_name www.yanjie.com yanjie.com;
		return 301 https://$server_name$request_uri;
	}
}
