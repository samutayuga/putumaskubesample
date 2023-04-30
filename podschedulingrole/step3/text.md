# Create a deployment with tolerant pod

Leave the `other-non-torelant` deployment in `Pending`.

Create another deployment in `magellan` namespace with `nginx:alpine` image and make its pod tolerant to `controlplane` node which its taint  is `owner=ootcloud:NoSchedule`. This represents the deployment from ootcloud team. In real world scenario, this could be a kind of standard apps with low computing capacity requirement.

Initiate the manifest creation with imperative approach,
Save the manifest into a file `/tmp/small-ootcloud-tolerant.yaml`

`kubectl create deployment small-ootcloud-tolerant --image=nginx:alpine -n magellan  --dry-run=client -o yaml > /tmp/small-ootcloud-tolerant.yaml`{{exec}}

Open the manifest in edit mode,

`vim /tmp/small-ootcloud-tolerant.yaml`{{exec}}

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  creationTimestamp: null
  labels:
    app: small-ootcloud-tolerant
  name: small-ootcloud-tolerant
  namespace: magellan
spec:
  replicas: 1
  selector:
    matchLabels:
      app: small-ootcloud-tolerant
  strategy: {}
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: small-ootcloud-tolerant
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
    app: small-ootcloud-tolerant
  name: small-ootcloud-tolerant
  namespace: magellan
spec:
  replicas: 1
  selector:
    matchLabels:
      app: small-ootcloud-tolerant
  strategy: {}
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: small-ootcloud-tolerant
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
                      - "SMALL"
                      - "MEDIUM"
      tolerations:
        - key: owner
          operator: Equal
          value: ootcloud
          effect: NoSchedule
status: {}
```

Observe the events inside the namespace `magellan`, try to extract the event object and output it into go-template

`kubectl get events -n magellan -o go-template='{{ range $k,$v := .items }}{{ .involvedObject.kind}}{{"/"}}{{.involvedObject.name}}{{"\t"}}{{ .source.component}}{{"\t"}}{{ .reason}}{{"\t"}}{{.message}}{{"\n"}}{{end}}'`

Example output,

```text
Pod/other-non-tolerant-9c8544db6-k7mk8  default-scheduler       FailedScheduling        0/1 nodes are available: 1 node(s) had untolerated taint {owner: ootcloud}. preemption: 0/1 nodes are available: 1 Preemption is not helpful for scheduling..
...
Pod/small-ootcloud-tolerant-6cd8855b7f-tqlmn    default-scheduler       Scheduled       Successfully assigned magellan/small-ootcloud-tolerant-6cd8855b7f-tqlmn to controlplane
...
Pod/small-ootcloud-tolerant-6cd8855b7f-tqlmn    kubelet Started Started container nginx
...
```

The deployment rollout is successfull

`kubectl rollout status deployment small-ootcloud-tolerant -n magellan`{{exec}}

The result is,

```text
deployment "small-ootcloud-tolerant" successfully rolled out
```
