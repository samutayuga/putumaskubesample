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
    "response_code": 200,
    "message": "200 OK",
    "from": "frontend-5587bb86db-4h58p",
    "to": "http://backend.magellan.svc.cluster.local:8081/ping",
    "dns_checking": "backend.magellan.svc.cluster.local:8081 is resolved succesfully, ip address [10.106.106.148] "
  },
  {
    "response_code": -1,
    "message": "Get \"https://www.google.com\": dial tcp 142.251.12.104:443: i/o timeout",
    "from": "frontend-5587bb86db-4h58p",
    "to": "https://www.google.com",
    "dns_checking": "www.google.com is resolved succesfully, ip address [142.251.10.103 142.251.10.99 142.251.10.105 142.251.10.104 142.251.10.106 142.251.10.147 2404:6800:4003:c11::68 2404:6800:4003:c11::67 2404:6800:4003:c11::93 2404:6800:4003:c11::63] "
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


