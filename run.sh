#!/bin/bash
iam=$(id | awk -F'd=' '{print $2}' | awk '{print $1}')
sed -i "s_apache:x:48:48:Apache:/var/www:/sbin/nologin_apache:x:$iam:0:Apache:/var/www:/sbin/nologin_g" /etc/passwd
/usr/sbin/httpd -DFOREGROUND

