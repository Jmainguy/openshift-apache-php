### Basic Apache container with PHP on Openshift

#### Requirements
1. Docker daemon installed, running, and you have access to use
2. `oc` command, https://docs.openshift.com/container-platform/3.11/cli_reference/get_started_cli.html
3. Git

#### Build locally with docker, then push to openshift registry
My payload was payload.tar.gz which had all my site contents. To create your own, for eg:
```
$ cat index.html
<html>
<body>
<p>
hello dockerworld
</p>
</body>
</html>
```

Then tar it up:
```
$ tar zcvf payload.tar.gz index.html
```

And confirm:
```
$ tar ztvf payload.tar.gz
-rw-r--r--  0 jmainguy staff      57 Feb  5 15:34 index.html
```

#### Create web project
```oc new-project ${USER}-web```

#### Get oc token
```oc whoami -t```

#### Get the url for registry
```oc get route docker-registry -n default```

*NOTE:* If you get an error, ask your openshift admin for the docker registry url

### login to registry with docker
```docker login -u jmainguy -p 82pHug7j72tmyqPjTCn157JGXL9QV3as docker-registry-default.apps.example.com``` 

*NOTE:* As a single command:

##### OSX (Docker version 18.x+)
```
$ echo "$(oc whoami -t)" | \
   docker login -u $USER --password-stdin $(oc get route docker-registry -n default --no-headers | awk '{print $2}')
Login Succeeded
```

##### Linux (Docker version 1.13.1 - API version 1.26)
```
$ docker login -u $USER -p $(oc whoami -t) $(oc get route docker-registry -n default --no-headers | awk '{print $2}')
Login Succeeded
```


### Build image
```docker build -t=docker-registry-default.apps.example.com/web/example .```
### Push image
```docker push docker-registry-default.apps.example.com/web/example```
### Deploy
```oc new-app web/example --name=example```
### Expose svc and route
```oc expose svc/example```

-------------------------------------

### Example run

#### Build step
```
$ docker build -t=$(oc get route docker-registry -n default --no-headers | awk '{print $2}')/slm-web/example .
Sending build context to Docker daemon  87.55kB
Step 1/15 : FROM centos:centos6
 ---> 0cbf37812bff
Step 2/15 : ENV maintainer="Jonathan Mainguy <jon@soh.re>"
 ---> Using cache
 ---> bcd4cfe9160b
Step 3/15 : RUN yum install -y epel-release
 ---> Using cache
 ---> dd883338fb19
Step 4/15 : RUN yum install -y php-pear httpd php-pdo php-mysql php-mbstring php-snmp php-common php-cli php-ldap php-mcrypt php-gd php-devel php-bcmath php
 ---> Using cache
 ---> a50ae6940107
Step 5/15 : ADD payload.tar.gz /var/www/html/
 ---> 5832d2c904e0
Step 6/15 : RUN chgrp -R 0 /var/www/html/     && chmod -R g+rwX /var/www/html/
 ---> Running in 943b7c2dfc4d
Removing intermediate container 943b7c2dfc4d
 ---> bddaafea6065
Step 7/15 : RUN chgrp -R 0 /etc     && chmod -R g+rwX /etc
 ---> Running in 703f290cf516
Removing intermediate container 703f290cf516
 ---> 3405e4888530
Step 8/15 : RUN chgrp -R 0 /var/lib/php/session/     && chmod -R g+rwX /var/lib/php/session/
 ---> Running in b0d76100305b
Removing intermediate container b0d76100305b
 ---> 86163659ee64
Step 9/15 : RUN chmod 777 /etc/passwd
 ---> Running in 2924750223e5
Removing intermediate container 2924750223e5
 ---> 7f3906715b20
Step 10/15 : RUN sed -i 's/Listen 80/Listen 8080/g' /etc/httpd/conf/httpd.conf
 ---> Running in 4dd94c611445
Removing intermediate container 4dd94c611445
 ---> 826bfbae49fe
Step 11/15 : RUN sed -i 's_logs/_/tmp/_g' /etc/httpd/conf/httpd.conf
 ---> Running in 931267401c0f
Removing intermediate container 931267401c0f
 ---> 9a5dd06b9feb
Step 12/15 : RUN sed -i 's_run/_/tmp/_g' /etc/httpd/conf/httpd.conf
 ---> Running in 9b92365e6168
Removing intermediate container 9b92365e6168
 ---> 092732ca6f9f
Step 13/15 : ADD run.sh /tmp/run.sh
 ---> a25be250cf8e
Step 14/15 : EXPOSE 8080
 ---> Running in d36427119e49
Removing intermediate container d36427119e49
 ---> 52fd0abbc317
Step 15/15 : CMD ["/tmp/run.sh"]
 ---> Running in 5cc249ca9ca6
Removing intermediate container 5cc249ca9ca6
 ---> 51eeb273e1d5
Successfully built 51eeb273e1d5
Successfully tagged docker-registry-default.apps.somedom.com/joeuser-web/example:latest
```

#### Pushing image
```
$ docker push $(oc get route docker-registry -n default --no-headers | awk '{print $2}')/${USER}-web/example
The push refers to repository [docker-registry-default.apps.somedom.com/joeuser-web/example]
c87920ba9299: Pushed
a2acd152fb41: Pushed
9e676f9f8d28: Pushed
ff633cb6d25c: Pushed
2dca8a5e537a: Pushed
bb84cbc222ef: Pushed
3d3d15712f0d: Pushed
a2b48514a1ee: Pushed
91e6b08a9b29: Pushed
79077cb5ccbd: Pushed
2e616709e0dd: Pushed
5d574ede99e4: Pushed
latest: digest: sha256:e60453a64b9d277eab944c0f7dcb4982c0ff9bf719ab593eb82bc6e79168ad0b size: 2826
```

#### Confirm image is in registry
```
$ oc get images | grep ${USER}-web
sha256:e60453a64b9d277eab944c0f7dcb4982c0ff9bf719ab593eb82bc6e79168ad0b   docker-registry.default.svc:5000/joeuser-web/example@sha256:e60453a64b9d277eab944c0f7dcb4982c0ff9bf719ab593eb82bc6e79168ad0b
```
