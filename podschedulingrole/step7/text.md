# Validate if deployment from kuiperbelt team can schedule on node with owner=kuiperbelt taint

So far, we have seen the deployment from `any-kuiperbelt` team remains in `pending` state because its pods is not tolerant to the node, as what the message in the events,

```text
Pod/any-kuiperbelt-6dbc7774bd-5gh5w   0/1 nodes are available: 1 node(s) had untolerated taint {owner: oortcloud}. preemption: 0/1 nodes are available: 1 Preemption is not helpful for scheduling..
```
In cluster, at this point of time, pod and deployments status are given as below,

`kubectl get pod,deployment -A -l 'app in (any-kuiperbelt, small-oortcloud-tolerant, large-oortcloud-tolerant)'`{{exec}}

```text
NAME                                      READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/large-oortcloud-tolerant   1/1     1            1           8s
deployment.apps/other-non-tolerant        0/1     1            0           10m
deployment.apps/small-oortcloud-tolerant   0/1     1            0           9m21s

NAME                                           READY   STATUS    RESTARTS   AGE
pod/large-oortcloud-tolerant-6fd5849cb8-p59gs   1/1     Running   0          8s
pod/other-non-tolerant-9c8544db6-h2pwm         0/1     Pending   0          10m
pod/small-oortcloud-tolerant-6cd8855b7f-svnbx   0/1     Pending   0          3m

```

Lets change node's taint,

`kubectl taint node controlplane owner=kuiperbelt:NoSchedule --overwrite`{{exec}}

Make sure the taint is applied properly,

`kubectl describe node controlplane |grep "Taints:"`{{exec}}

```text
Taints:             owner=kuiperbelt:NoSchedule
```

Restart the deployment `any-kuiperbelt`.

`kubectl scale deployment -n kuiperbelt any-kuiperbelt --replicas 0`{{exec}}

`kubectl scale deployment -n kuiperbelt any-kuiperbelt --replicas 1`{{exec}}

Restart the `small-oortcloud-tolerant` and `large-oortcloud-tolerant` as well.

`kubectl scale deployment -n oortcloud small-oortcloud-tolerant --replicas 0`{{exec}}

`kubectl scale deployment -n oortcloud small-oortcloud-tolerant --replicas 1`{{exec}}

`kubectl scale deployment -n oortcloud large-oortcloud-tolerant --replicas 0`{{exec}}

`kubectl scale deployment -n oortcloud large-oortcloud-tolerant --replicas 1`{{exec}}

## Verify oortcloud namespace
All workloads belong to oortcloud team should not be able to schedule because it is not tolerant to the node.

`kubectl get events -n oortcloud -o go-template='{{ range .items }}{{ .involvedObject.kind}}{{"/"}}{{.involvedObject.name}}{{"\t"}}{{.message}}{{"\n"}}{{end}}' |grep Pod`{{exec}}

```text
Pod/large-oortcloud-tolerant-57c74d458c-gnw6n   0/1 nodes are available: 1 node(s) had untolerated taint {owner: kuiperbelt}. preemption: 0/1 nodes are available: 1 Preemption is not helpful for scheduling..
...
Pod/small-oortcloud-tolerant-6546b85b4d-nmn9f   0/1 nodes are available: 1 node(s) had untolerated taint {owner: kuiperbelt}. preemption: 0/1 nodes are available: 1 Preemption is not helpful for scheduling..
...
```

## Verify kuiperbelt namespace

Final state of the `any-kuiperbelt` is `Started`

`kubectl get deployment,pod -A -l 'app in (any-kuiperbelt, small-oortcloud-tolerant,large-oortcloud-tolerant)'`{{exec}}

```text
controlplane $ kubectl get deployment,pod -A -l 'app in (any-kuiperbelt, small-oortcloud-tolerant,large-oortcloud-tolerant)'
NAMESPACE    NAME                                       READY   UP-TO-DATE   AVAILABLE   AGE
kuiperbelt   deployment.apps/any-kuiperbelt             1/1     1            1           19m
oortcloud    deployment.apps/large-oortcloud-tolerant   0/1     1            0           5m58s
oortcloud    deployment.apps/small-oortcloud-tolerant   0/1     1            0           15m

NAMESPACE    NAME                                            READY   STATUS    RESTARTS   AGE
kuiperbelt   pod/any-kuiperbelt-7bc984dc5c-bd2fr             1/1     Running   0          112s
oortcloud    pod/large-oortcloud-tolerant-57c74d458c-gnw6n   0/1     Pending   0          103s
oortcloud    pod/small-oortcloud-tolerant-6546b85b4d-nmn9f   0/1     Pending   0          106s
```

Yes, only the `any-kuiperbelt` is now up and running, while the rest are in `Pending` as expected
