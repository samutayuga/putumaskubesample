# A deployment with the non tolerant pod will not be able to rollout

## Step

Create namespace

`kubectl create namespace kuiperbelt`{{exec}}

Create a deployment `any-kuiperbelt` in `kuiperbelt` namespace with `nginx:alpine` image. This deployment is belong to the team `kuiperbelt` which is not tolerant to the taint applied in node.

Initiate the manifest creation with imperative approach,
Save the manifest into a file `/tmp/any-kuiperbelt.yaml`

`kubectl create deployment any-kuiperbelt --image=nginx:alpine -n kuiperbelt  --dry-run=client -o yaml > /tmp/any-kuiperbelt.yaml`{{exec}}

Open the manifest in edit mode,

`vim /tmp/any-kuiperbelt.yaml`{{exec}}

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  creationTimestamp: null
  labels:
    app: any-kuiperbelt
  name: any-kuiperbelt
  namespace: kuiperbelt
spec:
  replicas: 1
  selector:
    matchLabels:
      app: any-kuiperbelt
  strategy: {}
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: any-kuiperbelt
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
    app: any-kuiperbelt
  name: any-kuiperbelt
  namespace: kuiperbelt
spec:
  replicas: 1
  selector:
    matchLabels:
      app: any-kuiperbelt
  strategy: {}
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: any-kuiperbelt
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
              - key: compute
                operator: Exists
      tolerations:
      - key: owner
        operator: Equal
        value: kuiperbelt
        effect: NoSchedule
status: {}
```

Apply it,

`kubectl apply -f /tmp/any-kuiperbelt.yaml`{{exec}}

## Verify the result

Verify if the scheduling is failed, by extracting events inside the namespace `kuiperbelt`. Get necessary columns from the event object and output it into `go-template`

`kubectl get events -n kuiperbelt -o go-template='{{ range .items }}{{ .involvedObject.kind}}{{"/"}}{{.involvedObject.name}}{{"\t"}}{{.message}}{{"\n"}}{{end}}' |grep Pod`{{exec}}

Example output,

```text
Pod/any-kuiperbelt-6b8d869686-4w69v   0/1 nodes are available: 1 node(s) had untolerated taint {owner: oortcloud}. preemption: 0/1 nodes are available: 1 Preemption is not helpful for scheduling..
...


```
The error `had untolerated taint {owner: oortcloud}` indicates that the problem is the pod is not tolerant with the node.


The deployment rollout is failed

`kubectl rollout status deployment any-kuiperbelt -n kuiperbelt`{{exec}}

The result is,

```text
Waiting for deployment "any-kuiperbelt" rollout to finish: 0 of 1 updated replicas are available...
```

Check the pod and deployment in kuiperbelt namespace

`kubectl get deployment,pod -A -l 'app in (any-kuiperbelt)' `{{exec}}

```text
NAME                               READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/any-kuiperbelt   0/1     1            0           82s

NAME                                    READY   STATUS    RESTARTS   AGE
pod/any-kuiperbelt-6b8d869686-4w69v   0/1     Pending   0          82s
```
