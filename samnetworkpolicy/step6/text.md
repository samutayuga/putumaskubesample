# Testing with network policy

Create a `network policy` to regulate the inbound and outbound traffic so that, 
* `frontend` outgoing traffic is blocked except to the backend
* `backend` incoming traffic is only allowed if it is from frontend and its outgoing traffic is blocked except to the storage. 
* `storage` incoming traffic is only allowed if it is from backend and its outgoing traffic is blocked. 
* The access to internet is not allowed except from the `storage`
* The outgoing traffic to the `kube dns` is always allowed

There will be 3 different network policies in the `magellan` namespace. 

`frontend`

```
kubectl apply -n magellan -f - << EOF
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: fe-netpol
  namespace: magellan
spec:
  podSelector:
    matchLabels:
      app: frontend
  policyTypes:
  - Egress
  - Ingress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          kubernetes.io/metadata.name: tester
      podSelector:
        matchLabels:
          app: client-mock
  egress:
  - to:
    - namespaceSelector: {}
      podSelector:
        matchLabels:
          k8s-app: kube-dns
    ports:
    - port: 53
      protocol: UDP
  - to:
    - podSelector:
        matchLabels:
          app: backend
EOF
```{{exec}}

This will not work without enabling the backend for the ingress

`backend`

```
kubectl apply -n magellan -f - << EOF
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: be-netpol
  namespace: magellan
spec:
  podSelector:
    matchLabels:
      app: backend
  policyTypes:
  - Egress
  - Ingress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          kubernetes.io/metadata.name: tester
      podSelector:
        matchLabels:
          app: client-mock
    - podSelector:
        matchLabels:
          app: frontend
  egress:
  - to:
    - ipBlock:
        cidr: 0.0.0.0/0
    - namespaceSelector: {}
      podSelector:
        matchLabels:
          k8s-app: kube-dns
    ports:
    - port: 53
      protocol: UDP
EOF
```{{exec}}

`storage`

```
kubectl apply -n magellan -f - << EOF
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: st-netpol
  namespace: magellan
spec:
  podSelector:
    matchLabels:
      app: storage
  policyTypes:
  - Egress
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: backend
    - namespaceSelector:
        matchLabels:
          kubernetes.io/metadata.name: tester
      podSelector:
        matchLabels:
          app: tester-st 
  egress:
  - to: 
    - namespaceSelector: {}
      podSelector:
        matchLabels:
          k8s-app: kube-dns
    ports:
      - port: 53
        protocol: UDP
  - to:
    - ipBlock:
        cidr: 0.0.0.0/0
EOF
```{{exec}}

Once it is applied in `magellan` namespace verify if it is created successfully

`kubectl describe netpol -n magellan fe-netpol`{{exec}}

`kubectl describe netpol -n magellan be-netpol`{{exec}}

`kubectl describe netpol -n magellan st-netpol`{{exec}}


