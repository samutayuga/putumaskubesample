# A deployment with the non tolerant pod will not be able to rollout

## Step

Create namespace

`kubectl create namespace magellan`{{exec}}

Create a deployment `other-non-tolerant` in `magellan` namespace with `nginx:alpine` image. This deployment is belong to the team `kuiperbelt` which is not tolerant to the taint applied in node. It tolerants to the taints defined as `owner=kuiperbelt:NoSchedule`

Initiate the manifest creation with imperative approach,
Save the manifest into a file `/tmp/other-kuiperbelt.yaml`

`kubectl create deployment other-kuiperbelt --image=nginx:alpine -n magellan  --dry-run=client -o yaml > /tmp/other-kuiperbelt.yaml`{{exec}}

Open the manifest in edit mode,

`vim /tmp/other-kuiperbelt.yaml`{{exec}}

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  creationTimestamp: null
  labels:
    app: other-kuiperbelt
  name: other-kuiperbelt
  namespace: magellan
spec:
  replicas: 1
  selector:
    matchLabels:
      app: other-kuiperbelt
  strategy: {}
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: other-kuiperbelt
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
    app: other-kuiperbelt
  name: other-kuiperbelt
  namespace: magellan
spec:
  replicas: 1
  selector:
    matchLabels:
      app: other-kuiperbelt
  strategy: {}
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: other-kuiperbelt
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
              - key: podSize
                operator: Exists
      tolerations:
      - key: owner
        operator: Equal
        value: kuiperbelt
        effect: NoSchedule
status: {}
```

Apply it,

`kubectl apply -f /tmp/other-kuiperbelt.yaml`{{exec}}

## Verify the result

Verify if the scheduling is failed, by extracting events inside the namespace `magellan`. Get necessary columns from the event object and output it into `go-template`

`kubectl get events -n magellan -o go-template='{{ range $k,$v := .items }}{{ .involvedObject.kind}}{{"/"}}{{.involvedObject.name}}{{"\t"}}{{.message}}{{"\n"}}{{end}}' |grep Pod`{{exec}}

Example output,

```text
Pod/other-kuiperbelt-6dbc7774bd-5gh5w   0/1 nodes are available: 1 node(s) had untolerated taint {owner: oortcloud}. preemption: 0/1 nodes are available: 1 Preemption is not helpful for scheduling..
...

```

The deployment rollout is failed

`kubectl rollout status deployment other-kuiperbelt -n magellan`{{exec}}

The result is,

```text
Waiting for deployment "other-kuiperbelt" rollout to finish: 0 of 1 updated replicas are available...
```

Check the pod and deployment in magellan namespace

`kubectl get deployment,pod -n magellan`{{exec}}

```text
NAME                               READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/other-kuiperbelt   0/1     1            0           2m56s

NAME                                    READY   STATUS    RESTARTS   AGE
pod/other-kuiperbelt-6dbc7774bd-5gh5w   0/1     Pending   0          2m56s
```
