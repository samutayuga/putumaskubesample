# Validate if the pod with the same rule still schedule in node with label podSize=MEDIUM

## Step

Check the inital state of the deployment in `magellan` namespace

`kubectl get deployment,pod -n magellan`{{exec}}

```text
NAME                                      READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/other-non-tolerant        0/1     1            0           23m
deployment.apps/small-ootcloud-tolerant   1/1     1            1           6m6s

NAME                                           READY   STATUS    RESTARTS   AGE
pod/other-non-tolerant-9c8544db6-gw7ls         0/1     Pending   0          23m
pod/small-ootcloud-tolerant-6cd8855b7f-zm2x9   1/1     Running   0          5m8s
```

With one pod in `Pending` and one in `Running`, it represents the pod that is accepted and not accepted by the node. Lets change node label to `podSize=MEDIUM`

`kubectl label node controlplane podSize=MEDIUM --overwrite`{{exec}}

Check if the node label has changed.

`kubectl describe node controlplane |grep -A 7  "Labels:"`{{exec}}

```text
controlplane $ k describe node controlplane 
Name:               controlplane
Roles:              control-plane
Labels:             beta.kubernetes.io/arch=amd64
                    ...
                    podSize=MEDIUM
...
```

Scale down then scale up the `small-ootcloud-tolerant` deployment  to trigger the pod rescheduling,

```
kubectl scale deployment -n magellan small-ootcloud-tolerant --replicas 0
kubectl scale deployment -n magellan small-ootcloud-tolerant --replicas 1
```{{exec}}

## Verify

Inspect the warning entry, try to extract the event object and output it into `go-template`

`kubectl get events -n magellan -o go-template='{{ range $k,$v := .items }}{{ .involvedObject.kind}}{{"/"}}{{.involvedObject.name}}{{"\t"}}{{.message}}{{"\n"}}{{end}}' |grep Pod`{{exec}}

Example output,

```text
Pod/other-non-tolerant-9c8544db6-gw7ls  0/1 nodes are available: 1 node(s) had untolerated taint {owner: ootcloud}. preemption: 0/1 nodes are available: 1 Preemption is not helpful for scheduling..
...
Pod/small-ootcloud-tolerant-6cd8855b7f-5cr2b    Successfully assigned magellan/small-ootcloud-tolerant-6cd8855b7f-5cr2b to controlplane
...
Pod/small-ootcloud-tolerant-6cd8855b7f-zm2x9    Successfully assigned magellan/small-ootcloud-tolerant-6cd8855b7f-zm2x9 to controlplane
...
```

Verify if the rollout is successfull

`kubectl rollout status deployment small-ootcloud-tolerant -n magellan`{{exec}}

The result is,

```text
deployment "small-ootcloud-tolerant" successfully rolled out
```

The magellan namespace now has one deployment in pending and one in running state same as before.

`kubectl get deployment,pod -n magellan`{{exec}}

```text
NAME                                      READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/other-non-tolerant        0/1     1            0           4m49s
deployment.apps/small-ootcloud-tolerant   1/1     1            1           3m1s

NAME                                           READY   STATUS    RESTARTS   AGE
pod/other-non-tolerant-9c8544db6-7dd5c         0/1     Pending   0          4m49s
pod/small-ootcloud-tolerant-6cd8855b7f-qz5f4   1/1     Running   0          65s
```
