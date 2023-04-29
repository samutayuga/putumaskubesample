# Create pod with the nodeSelector only in a namespace

Create namespace

```shell
kubectl create namespace magellan
```

Create a pod in `magellan` namespace with `nginx:alpine` image with nodeSelector set to `size:SMALL`
Save the manifest into a file `/tmp/no-tolerant.yaml`


```shell
kubectl run no-tolerant --image=nginx:alpine --overrides '{"spec": {"nodeSelector": {"size": "SMALL" } } }' -n magellan --dry-run=client -o yaml > /tmp/no-tolerant.yaml

```

Once it is applied, observe if pod is stuck in `Pending`.

Describe pod to gather more information.

```shell
kubectl describe pod -n magellan no-tolerant
```

