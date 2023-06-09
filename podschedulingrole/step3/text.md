# A deployment with tolerant pod and match nodeSelector label will be able to rollout

## Step

Leave the `any-kuiperbelt` deployment in `Pending`. Create a new namespace, `oortcloud`, `kubectl create namespace oortcloud`{{exec}}. In this namespace create a deployment with `nginx:alpine` image and make its pod tolerant to `controlplane` node which its taint  is `owner=oortcloud:NoSchedule`. This represents the deployment from `oortcloud` team. In addition to that, add the `nodeAffinity` to the pod for this deployment,
```yaml
affinity:
  nodeAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
      nodeSelectorTerms:
      - matchExpressions:
        - key: compute
          operator: In
          values:
          - SMALL
          - MEDIUM
    
```

Initiate the manifest creation with imperative approach,
Save the manifest into a file `/tmp/small-oortcloud-tolerant.yaml`

`kubectl create deployment small-oortcloud-tolerant --image=nginx:alpine -n oortcloud  --dry-run=client -o yaml > /tmp/small-oortcloud-tolerant.yaml`{{exec}}

Open the manifest in edit mode,

`vim /tmp/small-oortcloud-tolerant.yaml`{{exec}}

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  creationTimestamp: null
  labels:
    app: small-oortcloud-tolerant
  name: small-oortcloud-tolerant
  namespace: oortcloud
spec:
  replicas: 1
  selector:
    matchLabels:
      app: small-oortcloud-tolerant
  strategy: {}
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: small-oortcloud-tolerant
    spec:
      containers:
      - image: nginx:alpine
        name: nginx
        resources: {}
status: {}
```

At the pod level, add the tolerations and nodeAffinity, so that it becomes,

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  creationTimestamp: null
  labels:
    app: small-oortcloud-tolerant
  name: small-oortcloud-tolerant
  namespace: oortcloud
spec:
  replicas: 1
  selector:
    matchLabels:
      app: small-oortcloud-tolerant
  strategy: {}
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: small-oortcloud-tolerant
    spec:
      containers:
      - image: nginx:alpine
        name: nginx
        resources: {}
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
              - matchExpressions:
                  - key: "compute"
                    operator: "In"
                    values:
                      - "SMALL"
                      - "MEDIUM"
      tolerations:
        - key: owner
          operator: Equal
          value: oortcloud
          effect: NoSchedule
status: {}
```

Apply it,

`kubectl apply -f /tmp/small-oortcloud-tolerant.yaml`{{exec}}

## Verify

Observe the events inside the namespace `oortcloud`, try to extract the event object and output it into go-template

`kubectl get events -n oortcloud -o go-template='{{ range .items }}{{ .involvedObject.kind}}{{"/"}}{{.involvedObject.name}}{{"\t"}}{{.message}}{{"\n"}}{{end}}' |grep Pod`{{exec}}

Example output,

```text
Pod/small-oortcloud-tolerant-6546b85b4d-rsrsk   Successfully assigned oortcloud/small-oortcloud-tolerant-6546b85b4d-rsrsk to controlplane
...
```

Verify if the rollout is successfull

`kubectl rollout status deployment small-oortcloud-tolerant -n oortcloud`{{exec}}

The result is,

```text
deployment "small-oortcloud-tolerant" successfully rolled out
```

Cluster has one deployment in pending and one in running state,

`kubectl get deployment,pod -A -l 'app in (any-kuiperbelt, small-oortcloud-tolerant)'`{{exec}}

```text
controlplane $ kubectl get deployment,pod -A -l 'app in (any-kuiperbelt, small-oortcloud-tolerant)'
NAMESPACE    NAME                                       READY   UP-TO-DATE   AVAILABLE   AGE
kuiperbelt   deployment.apps/any-kuiperbelt             0/1     1            0           5m36s
oortcloud    deployment.apps/small-oortcloud-tolerant   1/1     1            1           2m33s

NAMESPACE    NAME                                            READY   STATUS    RESTARTS   AGE
kuiperbelt   pod/any-kuiperbelt-7bc984dc5c-hrm7p             0/1     Pending   0          5m36s
oortcloud    pod/small-oortcloud-tolerant-6546b85b4d-rsrsk   1/1     Running   0          2m33s
```
