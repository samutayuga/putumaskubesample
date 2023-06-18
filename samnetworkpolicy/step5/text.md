# Testing without network policy

Create a temporary pod to make the rest call to `frontend` service, by calling,

```shell
curl http://frontend.magellan.svc.cluster.local:8080/propagate
```
Use the `nginx:alpine` image

```
kubectl run testing-fe --image=nginx:alpine \
-it 
--rm 
--force 
-- 
wget -O- http://frontend.magellan.svc.cluster.local:8080/propagate
```{{exec}}





