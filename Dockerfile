FROM centos:centos6
ENV maintainer="Jonathan Mainguy <jon@soh.re>"
RUN yum install -y epel-release
RUN yum install -y php-pear httpd php-pdo php-mysql php-mbstring php-snmp php-common php-cli php-ldap php-mcrypt php-gd php-devel php-bcmath php
ADD payload.tar.gz /var/www/html/
RUN chgrp -R 0 /var/www/html/ \
    && chmod -R g+rwX /var/www/html/
RUN chgrp -R 0 /etc \
    && chmod -R g+rwX /etc
RUN chgrp -R 0 /var/lib/php/session/ \
    && chmod -R g+rwX /var/lib/php/session/
RUN chmod 777 /etc/passwd
RUN sed -i 's/Listen 80/Listen 8080/g' /etc/httpd/conf/httpd.conf
RUN sed -i 's_logs/_/tmp/_g' /etc/httpd/conf/httpd.conf
RUN sed -i 's_run/_/tmp/_g' /etc/httpd/conf/httpd.conf
ADD run.sh /tmp/run.sh
EXPOSE 8080
CMD ["/tmp/run.sh"]
