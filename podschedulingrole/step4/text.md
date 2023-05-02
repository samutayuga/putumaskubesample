# Validate if the pod with the same rule still schedule in node with label podSize=MEDIUM

## Step

Check the inital state of the deployment in `oortcloud` namespace

`kubectl get deployment,pod -n oortcloud`{{exec}}

```text
NAME                                      READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/other-non-tolerant        0/1     1            0           23m
deployment.apps/small-oortcloud-tolerant   1/1     1            1           6m6s

NAME                                           READY   STATUS    RESTARTS   AGE
pod/other-non-tolerant-9c8544db6-gw7ls         0/1     Pending   0          23m
pod/small-oortcloud-tolerant-6cd8855b7f-zm2x9   1/1     Running   0          5m8s
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

Scale down then scale up the `small-oortcloud-tolerant` deployment  to trigger the pod rescheduling,

```
kubectl scale deployment -n oortcloud small-oortcloud-tolerant --replicas 0
kubectl scale deployment -n oortcloud small-oortcloud-tolerant --replicas 1
```{{exec}}

## Verify

Inspect the warning entry, try to extract the event object and output it into `go-template`

`kubectl get events -n oortcloud -o go-template='{{ range $k,$v := .items }}{{ .involvedObject.kind}}{{"/"}}{{.involvedObject.name}}{{"\t"}}{{.message}}{{"\n"}}{{end}}' |grep Pod`{{exec}}

Example output,

```text
Pod/other-kuiperbelt-6b8d869686-4w69v   0/1 nodes are available: 1 node(s) had untolerated taint {owner: oortcloud}. preemption: 0/1 nodes are available: 1 Preemption is not helpful for scheduling..
Pod/small-oortcloud-tolerant-68cf48777c-kws6f   0/1 nodes are available: 1 node(s) didn't match Pod's node affinity/selector. preemption: 0/1 nodes are available: 1 Preemption is not helpful for scheduling..
Pod/small-oortcloud-tolerant-68cf48777c-z8mr8   Successfully assigned oortcloud/small-oortcloud-tolerant-68cf48777c-z8mr8 to controlplane
...
Pod/small-oortcloud-tolerant-76658bdf49-2ks2k   Successfully assigned oortcloud/
...
```

Verify if the rollout is successfull

`kubectl rollout status deployment small-oortcloud-tolerant -n oortcloud`{{exec}}

The result is,

```text
deployment "small-oortcloud-tolerant" successfully rolled out
```

The oortcloud namespace now has one deployment in pending and one in running state same as before.

`kubectl get deployment,pod -n oortcloud`{{exec}}

```text
NAME                                       READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/other-kuiperbelt           0/1     1            0           13m
deployment.apps/small-oortcloud-tolerant   1/1     1            1           7m57s

NAME                                            READY   STATUS    RESTARTS   AGE
pod/other-kuiperbelt-6b8d869686-4w69v           0/1     Pending   0          13m
pod/small-oortcloud-tolerant-76658bdf49-2ks2k   1/1     Running   0          2m26s
```
