# Validate if podSize=LARGE can schedule in the node

We have observed that the pod from oortcloud is able to sechedule either in node with `podSize=SMALL` or in node with `podSize=MEDIUM`, but not in the node with label, `podSize=LARGE`.

`kubectl get pod,deployment -A -l 'app in (other-kuiperbelt, small-oortcloud-tolerant)'`{{exec}}

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
                  - key: "podSize"
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

`kubectl get events -n oortcloud -o go-template='{{ range $k,$v := .items }}{{ .involvedObject.kind}}{{"/"}}{{.involvedObject.name}}{{"\t"}}{{.message}}{{"\n"}}{{end}}' |grep Pod`{{exec}}

```text
Pod/large-oortcloud-tolerant-5fd7797bb8-nj6jx   Successfully assigned oortcloud/large-oortcloud-tolerant-5fd7797bb8-nj6jx to controlplane
...
Pod/other-kuiperbelt-6b8d869686-4w69v   0/1 nodes are available: 1 node(s) had untolerated taint {owner: oortcloud}. preemption: 0/1 nodes are available: 1 Preemption is not helpful for scheduling..
...
Pod/small-oortcloud-tolerant-68cf48777c-z8mr8   Successfully assigned oortcloud/small-oortcloud-tolerant-68cf48777c-z8mr8 to controlplane
...
Pod/small-oortcloud-tolerant-76658bdf49-2ks2k   Successfully assigned oortcloud/small-oortcloud-tolerant-76658bdf49-2ks2k to controlplane
...
Pod/small-oortcloud-tolerant-76658bdf49-lp4kc   0/1 nodes are available: 1 node(s) didn't match Pod's node affinity/selector. preemption: 0/1 nodes are available: 1 Preemption is not helpful for scheduling..
```

Final state of the `large-oortcloud-tolerant` is `Started`

`kubectl get deployment,pod -A -l 'app in (other-kuiperbelt, small-oortcloud-tolerant)'`{{exec}}

```text
controlplane $ kubectl get deployment,pod -n oortcloud
NAME                                       READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/large-oortcloud-tolerant   1/1     1            1           2m51s
deployment.apps/other-kuiperbelt           0/1     1            0           23m
deployment.apps/small-oortcloud-tolerant   0/1     1            0           17m

NAME                                            READY   STATUS    RESTARTS   AGE
pod/large-oortcloud-tolerant-5fd7797bb8-nj6jx   1/1     Running   0          2m51s
pod/other-kuiperbelt-6b8d869686-4w69v           0/1     Pending   0          23m
pod/small-oortcloud-tolerant-76658bdf49-lp4kc   0/1     Pending   0          9m25s
```
