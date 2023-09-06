# Resources

## Prerequisite

`kubectl create namespace sun`{{exec}}

`kubectl config get-context --current --namespace sun `{{exec}}

`kubectl run 0509649a --image=nginx:1.17.3-alpine --labels type=runner,type_old=messenger`{{exec}}

`kubectl run 0509649b --image=nginx:1.17.3-alpine --labels type=worker`{{exec}}

`kubectl run 1428721e --image=nginx:1.17.3-alpine --labels type=worker`{{exec}}

`kubectl run 1428721f --image=nginx:1.17.3-alpine --labels type=worker`{{exec}}

`kubectl run 43b9a --image=nginx:1.17.3-alpine --labels type=test`{{exec}}

`kubectl run 4c09 --image=nginx:1.17.3-alpine --labels type=worker`{{exec}}

`kubectl run 4c35 --image=nginx:1.17.3-alpine --labels type=worker`{{exec}}

`kubectl run 4fe4 --image=nginx:1.17.3-alpine --labels type=worker`{{exec}}

`kubectl run 5555a --image=nginx:1.17.3-alpine --labels type=messenger`{{exec}}

`kubectl run 86cda --image=nginx:1.17.3-alpine --labels type=runner`{{exec}}

`kubectl run 8d1c --image=nginx:1.17.3-alpine --labels type=messenger`{{exec}}

`kubectl run a004a --image=nginx:1.17.3-alpine --labels type=runner`{{exec}}

`kubectl run a94128196 --image=nginx:1.17.3-alpine --labels type=runner,type_old=messenger`{{exec}}

`kubectl run afd79200c56a --image=nginx:1.17.3-alpine --labels type=worker`{{exec}}

`kubectl run b667 --image=nginx:1.17.3-alpine --labels type=worker`{{exec}}

`kubectl run fdb2 --image=nginx:1.17.3-alpine --labels type=worker`{{exec}}

## Run Scenario

Team Sunny needs to identify some of their Pods in namespace sun. They ask you to add a new label `protected: true` to all Pods with an existing label `type: worker` or `type: runner`. Also add an annotation `protected: do not delete this pod` to all Pods having the new label `protected: true`.