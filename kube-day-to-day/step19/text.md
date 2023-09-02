# Node Port

## Prerequsites

`kubectl create namespace jupiter`{{exec}}

`kubectl config set-context --current --namespace jupiter`{{exec}}

`kubectl create deployment jupiter-crew-deploy --image=nginx:1.17.3-alpine`{{exec}}

`kubectl expose deployment jupiter-crew-deploy --name=jupiter-crew-svc --port=8080 --target-port=80`{{exec}}



## Run the scenario

In namespace `jupiter` you'll find an apache Deployment (with one replica) named `jupiter-crew-deploy` and a `ClusterIP Service` called `jupiter-crew-svc` which exposes it. Change this service to a NodePort one to make it available on all nodes on port 30100.

Test the NodePort Service using the internal IP of all available nodes and the port `30100` using curl, you can reach the internal node IPs directly from your main terminal. On which nodes is the Service reachable? On which node is the Pod running?