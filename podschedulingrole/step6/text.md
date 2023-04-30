# Validate if podSize=LARGE can schedule in the node

We have observed that the pod from ootcloud is able to sechedule either in node with `podSize=SMALL` or in node with `podSize=MEDIUM`, but not in the node with label, `podSize=LARGE`.

`kubectl get pod,deployment -n magellan`{{exec}}

```text
NAME                                      READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/other-non-tolerant        0/1     1            0           57m
deployment.apps/small-ootcloud-tolerant   0/1     1            0           40m

NAME                                           READY   STATUS    RESTARTS   AGE
pod/other-non-tolerant-9c8544db6-k7mk8         0/1     Pending   0          57m
pod/small-ootcloud-tolerant-8547877cd6-2x2br   0/1     Pending   0          4m37s
```

Lets create the new pod that really requires the LARGE node.

Repeat the step 4,
`kubectl create deployment large-ootcloud-tolerant --image=nginx:alpine -n magellan  --dry-run=client -o yaml > /tmp/large-ootcloud-tolerant.yaml`{{exec}}

Open the manifest in edit mode,

`vim /tmp/large-ootcloud-tolerant.yaml`{{exec}}

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  creationTimestamp: null
  labels:
    app: large-ootcloud-tolerant
  name: large-ootcloud-tolerant
  namespace: magellan
spec:
  replicas: 1
  selector:
    matchLabels:
      app: large-ootcloud-tolerant
  strategy: {}
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: large-ootcloud-tolerant
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
    app: large-ootcloud-tolerant
  name: large-ootcloud-tolerant
  namespace: magellan
spec:
  replicas: 1
  selector:
    matchLabels:
      app: large-ootcloud-tolerant
  strategy: {}
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: large-ootcloud-tolerant
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
                  - key: "podSize"
                    operator: "In"
                    values: 
                    - "LARGE"
      tolerations:
        - key: owner
          operator: Equal
          value: ootcloud
          effect: NoSchedule
status: {}
```

then apply it,

`kubectl apply -f /tmp/large-ootcloud-tolerant.yaml`

Extact the events,

`kubectl get events -n magellan -o go-template='{{ range $k,$v := .items }}{{ .involvedObject.kind}}{{"/"}}{{.involvedObject.name}}{{"\t"}}{{ .source.component}}{{"\t"}}{{ .reason}}{{"\t"}}{{.message}}{{"\n"}}{{end}}'`

```text
Pod/large-ootcloud-tolerant     default-scheduler       Scheduled       Successfully assigned magellan/large-ootcloud-tolerant to controlplane
...
Pod/large-ootcloud-tolerant     kubelet Started Started container large-ootcloud-tolerant
Pod/other-non-tolerant  default-scheduler       FailedScheduling        0/1 nodes are available: 1 node(s) had untolerated taint {owner: ootcloud}. preemption: 0/1 nodes are available: 1 Preemption is not helpful for scheduling..
...
Pod/small-ootcloud-tolerant     kubelet Created Created container small-ootcloud-tolerant
Pod/small-ootcloud-tolerant     kubelet Started Started container small-ootcloud-tolerant
Pod/small-ootcloud-tolerant     kubelet Killing Stopping container small-ootcloud-tolerant
Pod/small-ootcloud-tolerant     default-scheduler       Scheduled       Successfully assigned magellan/small-ootcloud-tolerant to controlplane
Pod/small-ootcloud-tolerant     kubelet Pulled  Container image "nginx:alpine" already present on machine
Pod/small-ootcloud-tolerant     kubelet Created Created container small-ootcloud-tolerant
Pod/small-ootcloud-tolerant     kubelet Started Started container small-ootcloud-tolerant
Pod/small-ootcloud-tolerant     kubelet Killing Stopping container small-ootcloud-tolerant
Pod/small-ootcloud-tolerant     default-scheduler       FailedScheduling        0/1 nodes are available: 1 node(s) didn't match Pod's node affinity/selector. preemption: 0/1 nodes are available: 1 Preemption is not helpful for scheduling..
```

Final state of the `large-ootcloud-tolerant` is `Started`

```text
NAME                                      READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/large-ootcloud-tolerant   1/1     1            1           8s
deployment.apps/other-non-tolerant        0/1     1            0           10m
deployment.apps/small-ootcloud-tolerant   0/1     1            0           9m21s

NAME                                           READY   STATUS    RESTARTS   AGE
pod/large-ootcloud-tolerant-6fd5849cb8-p59gs   1/1     Running   0          8s
pod/other-non-tolerant-9c8544db6-h2pwm         0/1     Pending   0          10m
pod/small-ootcloud-tolerant-6cd8855b7f-svnbx   0/1     Pending   0          3m
```
