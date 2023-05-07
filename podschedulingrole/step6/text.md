# Validate if compute=LARGE can schedule in the node

We have observed that the pod from oortcloud is able to sechedule either in node with `compute=SMALL` or in node with `compute=MEDIUM`, but not in the node with label, `compute=LARGE`.

`kubectl get pod,deployment -A -l 'app in (any-kuiperbelt, small-oortcloud-tolerant)'`{{exec}}

```text
NAME                                      READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/other-non-tolerant        0/1     1            0           57m
deployment.apps/small-oortcloud-tolerant   0/1     1            0           40m

NAME                                           READY   STATUS    RESTARTS   AGE
pod/other-non-tolerant-9c8544db6-k7mk8         0/1     Pending   0          57m
pod/small-oortcloud-tolerant-8547877cd6-2x2br   0/1     Pending   0          4m37s
```

Lets create the new pod that really requires the LARGE node.

Repeat the step 4,
`kubectl create deployment large-oortcloud-tolerant --image=nginx:alpine -n oortcloud  --dry-run=client -o yaml > /tmp/large-oortcloud-tolerant.yaml`{{exec}}

Open the manifest in edit mode,

`vim /tmp/large-oortcloud-tolerant.yaml`{{exec}}

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  creationTimestamp: null
  labels:
    app: large-oortcloud-tolerant
  name: large-oortcloud-tolerant
  namespace: oortcloud
spec:
  replicas: 1
  selector:
    matchLabels:
      app: large-oortcloud-tolerant
  strategy: {}
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: large-oortcloud-tolerant
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
    app: large-oortcloud-tolerant
  name: large-oortcloud-tolerant
  namespace: oortcloud
spec:
  replicas: 1
  selector:
    matchLabels:
      app: large-oortcloud-tolerant
  strategy: {}
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: large-oortcloud-tolerant
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
                    - "LARGE"
      tolerations:
        - key: owner
          operator: Equal
          value: oortcloud
          effect: NoSchedule
status: {}
```

then apply it,

`kubectl apply -f /tmp/large-oortcloud-tolerant.yaml`{{exec}}

Extact the events,

`kubectl get events -n oortcloud -o go-template='{{ range .items }}{{ .involvedObject.kind}}{{"/"}}{{.involvedObject.name}}{{"\t"}}{{.message}}{{"\n"}}{{end}}' |grep Pod`{{exec}}

```text
Pod/large-oortcloud-tolerant-57c74d458c-sv4lt   Successfully assigned oortcloud/large-oortcloud-tolerant-57c74d458c-sv4lt to controlplane
...
```

Final state of the `large-oortcloud-tolerant` is `Started`

`kubectl get deployment,pod -A -l 'app in (any-kuiperbelt, small-oortcloud-tolerant, large-oortcloud-tolerant)'`{{exec}}

```text
controlplane $ kubectl get deployment,pod -A -l 'app in (any-kuiperbelt, small-oortcloud-tolerant, large-oortcloud-tolerant)'
NAMESPACE    NAME                                       READY   UP-TO-DATE   AVAILABLE   AGE
kuiperbelt   deployment.apps/any-kuiperbelt             0/1     1            0           14m
oortcloud    deployment.apps/large-oortcloud-tolerant   1/1     1            1           105s
oortcloud    deployment.apps/small-oortcloud-tolerant   0/1     1            0           11m

NAMESPACE    NAME                                            READY   STATUS    RESTARTS   AGE
kuiperbelt   pod/any-kuiperbelt-7bc984dc5c-hrm7p             0/1     Pending   0          14m
oortcloud    pod/large-oortcloud-tolerant-57c74d458c-sv4lt   1/1     Running   0          103s
oortcloud    pod/small-oortcloud-tolerant-6546b85b4d-pktrf   0/1     Pending   0          3m40s
```
