# basic apache container with php on openshift
## Requirements
1. docker daemon installed, running, and you have access to use
2. oc command, https://docs.openshift.com/container-platform/3.11/cli_reference/get_started_cli.html
3. git
## Build locally with docker, then push to openshift registry
My payload was payload.tar.gz which had all my site contents, replace that with your tar

You might also not want to land this index.html, feel free to remove it.
### Create web project
```oc new-project web```
### Get oc token
```oc whoami -t```
### Get the url for registry
```oc get route docker-registry -n default```
if you get an error, ask your openshift adming for the docker registry url
### login to registry with docker
```docker login -u jmainguy -p 82pHug7j72tmyqPjTCn157JGXL9QV3as docker-registry-default.apps.example.com``` 

*NOTE:* As a single command
```
echo "$(oc whoami -t)" | docker login -u smingolelli --password-stdin $(oc get route docker-registry -n default --no-headers | awk '{print $2}')
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
