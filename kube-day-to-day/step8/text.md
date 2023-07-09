# Deployment: Rollout, Rollback

## Prerequisite

* Create a namespace

`kubectl create namespace neptune`{{exec}}

* Create a deployment, `api-new-c32` then upgrade image 


`kubectl create deployment api-new-c32 -n neptune --image=nginx:alpine`{{exec}}

`kubectl scale deployment api-new-c32 -n neptune --replicas 4`{{exec}}

`kubectl set image -n neptune deployment/api-new-c32 api-new-c32=busybox:alpine`{{exec}}

`kubectl set image -n neptune deployment/api-new-c32 api-new-c32=nginx:alpine-1.2.3`{{exec}}

* Check the rollout history

`kubectl rollout history deployment -n neptune api-new-c32`{{exec}}

## Scenario

There is an existing Deployment named `api-new-c32` in Namespace `neptune`. A developer did make an update to the Deployment but the updated version never came online. Check the Deployment history and find a revision that works, then rollback to it. Could you tell Team Neptune what the error was so it doesn't happen again?