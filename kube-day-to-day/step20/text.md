# Network Policy

## Prerequisites

`kubectl create namespace venus`{{exec}}

`kubectl config set-context --current --namespace venus`{{exec}}

`kubectl create deployment api --image=nginx:1.17.3`{{exec}}

`kubectl expose deployment api --name=api --labels id=api --port=2222 --target-port=80`{{exec}}

`kubectl create deployment frontend --image=nginx:1.17.3`{{exec}}

`kubectl expose deployment frontend --name=frontend --labels id=frontend --port=80 --target-port=80`{{exec}}

## Run scenario

In namespace `venus` you'll find two Deployments named `api` and `frontend`. 
Both deployments are exposed inside the cluster using Services. Create a NetworkPolicy named `np1` which restricts outgoing tcp connections from Deployment `frontend` and only allows those going to Deployment `api`. 
Make sure the NetworkPolicy still allows outgoing traffic on UDP/TCP ports 53 for DNS resolution.

Test using: wget www.google.com and wget api:2222 from a Pod of Deployment frontend.