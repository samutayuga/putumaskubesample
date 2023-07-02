# Testing without network policy

Create a temporary pod to initiate the REST call from `frontend` service,

```shell
wget -S -O- http://frontend.magellan.svc.cluster.local:8080/propagate
```
Use the `nginx:alpine` image

```
kubectl run client-mock --image=nginx:alpine --labels app=client-mock \
-it  --rm  --force \
--  wget -S -O- http://frontend.magellan.svc.cluster.local:8080/propagate
```{{exec}}

This will give result,
```json
[
  {
    "ResponseCode": 200,
    "ResponseMessage": "200 OK",
    "Origin": "frontend-d69f6bfc6-kgswl",
    "Destination": "http://frontend.magellan.svc.cluster.local:8080/ping"
  },
  {
    "ResponseCode": 200,
    "ResponseMessage": "200 OK",
    "Origin": "frontend-d69f6bfc6-kgswl",
    "Destination": "http://backend.magellan.svc.cluster.local:8081/ping"
  },
  {
    "ResponseCode": 200,
    "ResponseMessage": "200 OK",
    "Origin": "frontend-d69f6bfc6-kgswl",
    "Destination": "http://storage.magellan.svc.cluster.local:8082/ping"
  },
  {
    "ResponseCode": 200,
    "ResponseMessage": "200 OK",
    "Origin": "frontend-d69f6bfc6-kgswl",
    "Destination": "https://www.google.com"
  }
]
```

Repeat the step for initiating the call from `backend` and `storage`

```
kubectl run client-mock --image=nginx:alpine --labels app=client-mock -it  --rm --force \
--  wget -S -O- http://backend.magellan.svc.cluster.local:8081/propagate
```{{exec}}

The result will be,

```json
[
  {
    "ResponseCode": 200,
    "ResponseMessage": "200 OK",
    "Origin": "backend-b685b6b7b-xjx6g",
    "Destination": "http://backend.magellan.svc.cluster.local:8081/ping"
  },
  {
    "ResponseCode": 200,
    "ResponseMessage": "200 OK",
    "Origin": "backend-b685b6b7b-xjx6g",
    "Destination": "http://storage.magellan.svc.cluster.local:8082/ping"
  },
  {
    "ResponseCode": 200,
    "ResponseMessage": "200 OK",
    "Origin": "backend-b685b6b7b-xjx6g",
    "Destination": "http://frontend.magellan.svc.cluster.local:8080/ping"
  },
  {
    "ResponseCode": 200,
    "ResponseMessage": "200 OK",
    "Origin": "backend-b685b6b7b-xjx6g",
    "Destination": "https://www.google.com"
  }
]
```

```
kubectl run client-mock --image=nginx:alpine --labels app=client-mock -it --rm --force \
-- wget -S -O- http://storage.magellan.svc.cluster.local:8082/propagate
```{{exec}}

The result will be,

```json
[
  {
    "ResponseCode": 200,
    "ResponseMessage": "200 OK",
    "Origin": "storage-5d9c7b77f4-jhr58",
    "Destination": "http://storage.magellan.svc.cluster.local:8082/ping"
  },
  {
    "ResponseCode": 200,
    "ResponseMessage": "200 OK",
    "Origin": "storage-5d9c7b77f4-jhr58",
    "Destination": "http://frontend.magellan.svc.cluster.local:8080/ping"
  },
  {
    "ResponseCode": 200,
    "ResponseMessage": "200 OK",
    "Origin": "storage-5d9c7b77f4-jhr58",
    "Destination": "http://backend.magellan.svc.cluster.local:8081/ping"
  },
  {
    "ResponseCode": 200,
    "ResponseMessage": "200 OK",
    "Origin": "storage-5d9c7b77f4-jhr58",
    "Destination": "https://www.google.com"
  }
]
```

All pods are able to call each others.


