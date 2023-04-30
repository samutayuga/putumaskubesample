# A deployment with tolerant pod and match nodeSelector label will be able to rollout

## Step

Leave the `other-non-torelant` deployment in `Pending`. With this, the status on `magellan` namespace is,

`kubectl get deployment,pod -n magellan`{{exec}}

```text
NAME                                 READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/other-non-tolerant   0/1     1            0           10m

NAME                                     READY   STATUS    RESTARTS   AGE
pod/other-non-tolerant-9c8544db6-gw7ls   0/1     Pending   0          10m
```

Create another deployment in `magellan` namespace with `nginx:alpine` image and make its pod tolerant to `controlplane` node which its taint  is `owner=ootcloud:NoSchedule`. This represents the deployment from ootcloud team.

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

Apply it,

`kubectl apply -f /tmp/small-ootcloud-tolerant.yaml`{{exec}}

## Verify

Observe the events inside the namespace `magellan`, try to extract the event object and output it into go-template

`kubectl get events -n magellan -o go-template='{{ range $k,$v := .items }}{{ .involvedObject.kind}}{{"/"}}{{.involvedObject.name}}{{"\t"}}{{.message}}{{"\n"}}{{end}}' |grep Pod`{{exec}}

Example output,

```text
Pod/other-non-tolerant-9c8544db6-gw7ls  0/1 nodes are available: 1 node(s) had untolerated taint {owner: ootcloud}. preemption: 0/1 nodes are available: 1 Preemption is not helpful for scheduling..
Pod/small-ootcloud-tolerant-6cd8855b7f-zm2x9    Successfully assigned magellan/small-ootcloud-tolerant-6cd8855b7f-zm2x9 to controlplane
...
```

Verify if the rollout is successfull

`kubectl rollout status deployment small-ootcloud-tolerant -n magellan`{{exec}}

The result is,

```text
deployment "small-ootcloud-tolerant" successfully rolled out
```

The magellan namespace now has one deployment in pending and one in running state,

`kubectl get deployment,pod -n magellan`{{exec}}

```text
NAME                                      READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/other-non-tolerant        0/1     1            0           2m5s
deployment.apps/small-ootcloud-tolerant   1/1     1            1           17s

NAME                                           READY   STATUS    RESTARTS   AGE
pod/other-non-tolerant-9c8544db6-7dd5c         0/1     Pending   0          2m5s
pod/small-ootcloud-tolerant-6cd8855b7f-khvxg   1/1     Running   0          17s
```
