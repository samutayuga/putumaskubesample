# Testing with network policy

Create a namespace called `tester`

`kubectl create namespace tester`{{exec}}

Create a temporary pod to initiate the REST call from `frontend` service,

```shell
curl http://frontend.magellan.svc.cluster.local:8080/propagate
```
Use the `nginx:alpine` image

```
kubectl run client-mock --image=nginx:alpine --labels app=client-mock -n tester \
-it  --rm  --force \
--  wget -S -O- http://frontend.magellan.svc.cluster.local:8080/propagate
```{{exec}}

This will give result,
```json
[
  {
    "ResponseCode": 200,
    "ResponseMessage": "200 OK",
    "Origin": "frontend-d69f6bfc6-p4c57",
    "Destination": "http://backend.magellan.svc.cluster.local:8081/ping"
  },
  {
    "ResponseCode": -1,
    "ResponseMessage": "Get \"http://storage.magellan.svc.cluster.local:8082/ping\": dial tcp 10.96.126.113:8082: i/o timeout",
    "Origin": "frontend-d69f6bfc6-p4c57",
    "Destination": "http://storage.magellan.svc.cluster.local:8082/ping"
  },
  {
    "ResponseCode": -1,
    "ResponseMessage": "Get \"https://www.google.com\": dial tcp 172.253.118.103:443: i/o timeout",
    "Origin": "frontend-d69f6bfc6-p4c57",
    "Destination": "https://www.google.com"
  },
  {
    "ResponseCode": -1,
    "ResponseMessage": "Get \"http://frontend.magellan.svc.cluster.local:8080/ping\": dial tcp 10.99.180.179:8080: i/o timeout",
    "Origin": "frontend-d69f6bfc6-p4c57",
    "Destination": "http://frontend.magellan.svc.cluster.local:8080/ping"
  }
]
```

Repeat the step for initiating the call from `backend` and `storage`

```
kubectl run client-mock --image=nginx:alpine --labels app=client-mock -n tester -it  --rm --force \
--  wget -S -O- http://backend.magellan.svc.cluster.local:8081/propagate
```{{exec}}

The result will be,

```json
[
  {
    "ResponseCode": 200,
    "ResponseMessage": "200 OK",
    "Origin": "backend-b685b6b7b-zjbdd",
    "Destination": "http://storage.magellan.svc.cluster.local:8082/ping"
  },
  {
    "ResponseCode": -1,
    "ResponseMessage": "Get \"https://www.google.com\": dial tcp 74.125.68.147:443: i/o timeout",
    "Origin": "backend-b685b6b7b-zjbdd",
    "Destination": "https://www.google.com"
  },
  {
    "ResponseCode": -1,
    "ResponseMessage": "Get \"http://frontend.magellan.svc.cluster.local:8080/ping\": dial tcp 10.106.29.216:8080: i/o timeout",
    "Origin": "backend-b685b6b7b-zjbdd",
    "Destination": "http://frontend.magellan.svc.cluster.local:8080/ping"
  },
  {
    "ResponseCode": -1,
    "ResponseMessage": "Get \"http://backend.magellan.svc.cluster.local:8081/ping\": dial tcp 10.111.42.95:8081: i/o timeout",
    "Origin": "backend-b685b6b7b-zjbdd",
    "Destination": "http://backend.magellan.svc.cluster.local:8081/ping"
  }
]
```


All pods are able to call each others.


