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
    matchExpressions:
      - key: app
        operator: In
        values:
        - frontend
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - podSelector:
        matchLabel:
          app: tester
  egress:
  - ports:
    - port: 53
      protocol: TCP
    - port: 53
      protocol: UDP
  - to:
    - podSelector:
        matchExpressions:
        - key: app
          operator: In
          values:
          - backend
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
    matchExpressions:
    - key: app
      operator: In
      values:
      - backend
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - podSelector:
        matchExpressions:
        - key: app
          operator: In
          values:
          - frontend
  egress:
  - to:
    - port: 53
      protocol: TCP
    - port: 53
      protocol: UDP
  - podSelector:
      matchExpressions:
      - key: app
        operator: In
        values:
        - storage
EOF
```{{exec}}



