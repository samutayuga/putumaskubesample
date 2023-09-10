# Wrong livenes check

## Prerequisite

`kubectl create namespace earth`{{exec}}

`kubectl config set-context --current --namespace earth`{{exec}}

`mkdir -p /opt/course/p3`{{exec}}

```shell
kubectl -n earth apply -f - << EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  creationTimestamp: null
  labels:
    app: earth-3cc-web
  name: earth-3cc-web
spec:
  replicas: 4
  selector:
    matchLabels:
      app: earth-3cc-web
  strategy: {}
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: earth-3cc-web
    spec:
      containers:
      - image: nginx:1.16.1-alpine
        name: nginx
        resources: {}
        livenessProbe:
          tcpSocket:
            port: 82
status: {}
EOF
```{{exec}}

`kubectl expose deployment earth-3cc-web`{{exec}}



## Run Scenario

Management of EarthAG recorded that one of their Services stopped working. 
Dirk, the administrator, left already for the long weekend. All the information they could give you is that it was located in Namespace `earth` and that it stopped working after the latest rollout. All Services of EarthAG should be reachable from inside the cluster.

Find the Service, fix any issues and confirm it's working again. Write the reason of the error into file `/opt/course/p3/ticket-654.txt` so Dirk knows what the issue was.