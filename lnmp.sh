#!/usr/bin/env bash

#author:Distantskyline
#date:190801


cat <<-EOF >/etc/yum.repos.d/nginx.repo
[nginx-stable]
name=nginx stable repo
baseurl=http://nginx.org/packages/centos/\$releasever/\$basearch/
gpgcheck=1
enabled=1
gpgkey=https://nginx.org/keys/nginx_signing.key
EOF

if [ ! -e /yum.repos.d/epel.repo ];then
	yum -y install epel-release
fi

yum -y install epel-release

yum -y install nginx mariadb-server mariadb php php-gd php-mcrypt php-mbstring php-devel php-mysql php-xml php-fpm

systemctl enable nginx mariadb php-fpm
systemctl start nginx mariadb php-fpm


cat <<-EOF >/etc/nginx/conf.d/default.conf
server {
    listen       80;
    server_name  www.pycompute.com;

    charset koi8-r;
    access_log  /var/log/nginx/host.access.log  main;

    location / {
        root   /usr/share/nginx/html;
        index  index.php index.html index.htm;
    }

    error_page   404              /404.html;
    error_page   500 502 503 504  /50x.html;
    location = /50x.html {
        root   /usr/share/nginx/html;
    }

    location ~ \.php$ {
        root           /usr/share/nginx/html;
        fastcgi_pass   127.0.0.1:9000;
        fastcgi_index  index.php;
        fastcgi_param  SCRIPT_FILENAME  /usr/share/nginx/html/\$fastcgi_script_name;
        include        fastcgi_params;
    }
}
EOF

nginx -t
systemctl restart nginx

mysql -uroot -e "grant all privileges on *.* to 'zgh'@'localhost' identified by '123456';"

cat <<-EOF >/usr/share/nginx/html/index.php
<?php
\$link = mysql_connect('localhost', 'zgh', '123456');
if (!\$link) {
    die('Could not connect: ' . mysql_error());
}
echo 'Connected successfully';
mysql_close(\$link);
?>
EOF

