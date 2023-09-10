# Deployment and services

## Prerequisite

`kubectl create namespace sunny`{{exec}}

`kubectl config set-context --current --namespace sunny`{{exec}}

`kubectl create serviceaccount sa-sun-deploy`{{exec}}

`mkdir -p /opt/course/p2`{{exec}}


## Run Scenario

Team Sun needs a new Deployment named `sunny` with 4 replicas of image `nginx:1.17.3-alpine` in Namespace `sun`. The Deployment and its Pods should use the existing ServiceAccount `sa-sun-deploy`.

Expose the Deployment internally using a ClusterIP Service named `sun-srv` on port `9999`. The nginx containers should run as default on port 80. The management of Team Sun would like to execute a command to check that all Pods are running on occasion. Write that command into file  `/opt/course/p2/sunny_status_command.sh`. The command should use kubectl.