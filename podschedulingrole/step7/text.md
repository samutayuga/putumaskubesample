# Validate if deployment from kuiperbelt team can schedule on node with owner=kuiperbelt taint

So far, we have seen the deployment from `other-kuiperbelt` team remains in `pending` state because its pods is not tolerant to the node, as what the message in the events,

```text
Pod/other-kuiperbelt-6dbc7774bd-5gh5w   0/1 nodes are available: 1 node(s) had untolerated taint {owner: oortcloud}. preemption: 0/1 nodes are available: 1 Preemption is not helpful for scheduling..
```

The `magellan` namespace has the following status,

`kubectl get pod,deployment -n magellan`{{exec}}

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

`kubectl describe node controlplane |grep "Taints:`{{exec}}

```text
Taints:             owner=kuiperbelt:NoSchedule
```

Restart the deployment `other-kuiperbelt`.

`kubectl scale deployment -n magellan other-kuiperbelt --replicas 0`{{exec}}

`kubectl scale deployment -n magellan other-kuiperbelt --replicas 1`{{exec}}

Restart the `small-oortcloud-tolerant` and `large-oortcloud-tolerant` as well.

`kubectl scale deployment -n magellan small-oortcloud-tolerant --replicas 0`{{exec}}

`kubectl scale deployment -n magellan small-oortcloud-tolerant --replicas 1`{{exec}}

`kubectl scale deployment -n magellan large-oortcloud-tolerant --replicas 0`{{exec}}

`kubectl scale deployment -n magellan large-oortcloud-tolerant --replicas 1`{{exec}}

## Verify

`kubectl get events -n magellan -o go-template='{{ range $k,$v := .items }}{{ .involvedObject.kind}}{{"/"}}{{.involvedObject.name}}{{"\t"}}{{.message}}{{"\n"}}{{end}}' |grep Pod`{{exec}}

```text
Pod/large-oortcloud-tolerant-5fd7797bb8-8crxx   0/1 nodes are available: 1 node(s) had untolerated taint {owner: kuiperbelt}. preemption: 0/1 nodes are available: 1 Preemption is not helpful for scheduling..
...
Pod/other-kuiperbelt-6dbc7774bd-vvddq   Successfully assigned magellan/other-kuiperbelt-6dbc7774bd-vvddq to controlplane
....
Pod/small-oortcloud-tolerant-76658bdf49-lp4kc   0/1 nodes are available: 1 node(s) didn't match Pod's node affinity/selector. preemption: 0/1 nodes are available: 1 Preemption is not helpful for scheduling..
...
```

Final state of the `large-oortcloud-tolerant` is `Started`

`kubectl get deployment,pod -n magellan`{{exec}}

```text
NAME                                       READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/large-oortcloud-tolerant   0/1     1            0           17m
deployment.apps/other-kuiperbelt           1/1     1            1           37m
deployment.apps/small-oortcloud-tolerant   0/1     1            0           32m

NAME                                            READY   STATUS    RESTARTS   AGE
pod/large-oortcloud-tolerant-5fd7797bb8-8crxx   0/1     Pending   0          11m
pod/other-kuiperbelt-6dbc7774bd-vvddq           1/1     Running   0          3m7s
pod/small-oortcloud-tolerant-76658bdf49-tbp6n   0/1     Pending   0          11m
```

Yes, only the `other-kuiperbelt` is now up and running.
