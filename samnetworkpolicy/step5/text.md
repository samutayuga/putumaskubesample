# Testing without network policy

Create a temporary pod to initiate the REST call from `frontend` service,

`
wget -S -O- http://frontend.magellan.svc.cluster.local:8080/propagate
`{{exec}}


Use the `nginx:alpine` image

```shell
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
    "from": "frontend-5587bb86db-x5ch7",
    "to": "http://backend.magellan.svc.cluster.local:8081/ping",
    "dns_checking": "backend.magellan.svc.cluster.local:8081 is resolved succesfully, ip address [10.103.254.112] "
  },
  {
    "response_code": 200,
    "message": "200 OK",
    "from": "frontend-5587bb86db-x5ch7",
    "to": "https://www.google.com",
    "dns_checking": "www.google.com is resolved succesfully, ip address [74.125.130.104 74.125.130.105 74.125.130.99 74.125.130.106 74.125.130.103 74.125.130.147 2404:6800:4003:c11::67 2404:6800:4003:c11::69 2404:6800:4003:c11::68 2404:6800:4003:c11::93] "
  }
]
```

Repeat the step for initiating the call from `backend` and 

`storage`


```shell
kubectl run client-mock --image=nginx:alpine --labels app=client-mock -it  --rm --force \
--  wget -S -O- http://backend.magellan.svc.cluster.local:8081/propagate
```{{exec}}

The result will be,

```json
[
  {
    "response_code": 200,
    "message": "200 OK",
    "from": "backend-694c46dff-6db8c",
    "to": "http://frontend.magellan.svc.cluster.local:8080/ping",
    "dns_checking": "frontend.magellan.svc.cluster.local:8080 is resolved succesfully, ip address [10.109.51.207] "
  },
  {
    "response_code": 200,
    "message": "200 OK",
    "from": "backend-694c46dff-6db8c",
    "to": "https://www.google.com",
    "dns_checking": "www.google.com is resolved succesfully, ip address [142.250.4.105 142.250.4.104 142.250.4.103 142.250.4.147 142.250.4.99 142.250.4.106 2404:6800:4003:c06::68 2404:6800:4003:c06::69 2404:6800:4003:c06::6a 2404:6800:4003:c06::67] "
  }
]
```

`
kubectl run client-mock --image=nginx:alpine --labels app=client-mock -it --rm --force \
-- wget -S -O- http://storage.magellan.svc.cluster.local:8082/propagate
`{{exec}}

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


