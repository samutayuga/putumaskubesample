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
    "response_code": 200,
    "message": "200 OK",
    "from": "backend-6bcdf47dc8-t288v",
    "to": "http://frontend.magellan.svc.cluster.local:8080/ping",
    "dns_checking": "frontend.magellan.svc.cluster.local:8080 is resolved succesfully, ip address [10.96.150.124] "
  },
  {
    "response_code": 200,
    "message": "200 OK",
    "from": "backend-6bcdf47dc8-t288v",
    "to": "http://backend.magellan.svc.cluster.local:8081/ping",
    "dns_checking": "backend.magellan.svc.cluster.local:8081 is resolved succesfully, ip address [10.110.118.240] "
  },
  {
    "response_code": 200,
    "message": "200 OK",
    "from": "backend-6bcdf47dc8-t288v",
    "to": "https://www.google.com",
    "dns_checking": "www.google.com is resolved succesfully, ip address [74.125.24.106 74.125.24.104 74.125.24.99 74.125.24.105 74.125.24.147 74.125.24.103 2404:6800:4003:c02::69 2404:6800:4003:c02::93 2404:6800:4003:c02::67 2404:6800:4003:c02::68] "
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


