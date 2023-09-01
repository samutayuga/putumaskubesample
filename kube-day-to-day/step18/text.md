# Miss Configuration

## Prerequisite

`create namespace mars`

`kubectl create namespace mars`{{exec}}

`kubectl config set-context --current --namesapce mars`{{exec}}

Create a wrong nodeSelector on the service

`kubectl create deployment manager-api-deployment --image=nginx:1.17.3-alpine`{{exec}}

Expose the service

`kubectl expose deployment manager-api-deployment --port=4000 --target-port=80 --name=manager-api-svc --labels app=manager-api-deployment`{{exec}}

## Run scenario

There seems to be an issue in Namespace `mars` where the `ClusterIP` service `manager-api-svc` should make the Pods of Deployment `manager-api-deployment` available inside the cluster.

You can test this with curl `manager-api-svc.mars:4444` from a temporary nginx:alpine Pod. Check for the misconfiguration and apply a fix.

