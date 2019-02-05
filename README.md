### basic apache container with php on openshift

#### Requirements
1. docker daemon installed, running, and you have access to use
2. oc command, https://docs.openshift.com/container-platform/3.11/cli_reference/get_started_cli.html
3. git

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
```oc new-project web```

#### Get oc token
```oc whoami -t```

#### Get the url for registry
```oc get route docker-registry -n default```

#### login to registry with docker
```docker login -u jmainguy -p 82pHug7j72tmyqPjTCn157JGXL9QV3as docker-registry-default.apps.example.com``` 

#### Build image
```docker build -t=docker-registry-default.apps.example.com/web/example```

#### Push image
```docker push docker-registry-default.apps.example.com/web/example .```

#### Deploy
```oc new-app web/example --name=example```

#### Expose svc and route
```oc expose svc/example```
