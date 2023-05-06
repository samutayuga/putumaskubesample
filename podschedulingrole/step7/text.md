# Validate if deployment from kuiperbelt team can schedule on node with owner=kuiperbelt taint

So far, we have seen the deployment from `other-kuiperbelt` team remains in `pending` state because its pods is not tolerant to the node, as what the message in the events,

```text
Pod/other-kuiperbelt-6dbc7774bd-5gh5w   0/1 nodes are available: 1 node(s) had untolerated taint {owner: oortcloud}. preemption: 0/1 nodes are available: 1 Preemption is not helpful for scheduling..
```
In cluster, at this point of time, pod and deployments status are given as below,

`kubectl get pod,deployment -A -l 'app in (other-kuiperbelt, small-oortcloud-tolerant, large-oortcloud-tolerant)'`{{exec}}

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

Restart the deployment `other-kuiperbelt`.

`kubectl scale deployment -n kuiperbelt other-kuiperbelt --replicas 0`{{exec}}

`kubectl scale deployment -n kuiperbelt other-kuiperbelt --replicas 1`{{exec}}

Restart the `small-oortcloud-tolerant` and `large-oortcloud-tolerant` as well.

`kubectl scale deployment -n oortcloud small-oortcloud-tolerant --replicas 0`{{exec}}

`kubectl scale deployment -n oortcloud small-oortcloud-tolerant --replicas 1`{{exec}}

`kubectl scale deployment -n oortcloud large-oortcloud-tolerant --replicas 0`{{exec}}

`kubectl scale deployment -n oortcloud large-oortcloud-tolerant --replicas 1`{{exec}}

## Verify

`kubectl get events -n oortcloud -o go-template='{{ range .items }}{{ .involvedObject.kind}}{{"/"}}{{.involvedObject.name}}{{"\t"}}{{.message}}{{"\n"}}{{end}}' |grep Pod`{{exec}}

```text
Pod/large-oortcloud-tolerant-5fd7797bb8-8crxx   0/1 nodes are available: 1 node(s) had untolerated taint {owner: kuiperbelt}. preemption: 0/1 nodes are available: 1 Preemption is not helpful for scheduling..
...
Pod/other-kuiperbelt-6dbc7774bd-vvddq   Successfully assigned oortcloud/other-kuiperbelt-6dbc7774bd-vvddq to controlplane
....
Pod/small-oortcloud-tolerant-76658bdf49-lp4kc   0/1 nodes are available: 1 node(s) didn't match Pod's node affinity/selector. preemption: 0/1 nodes are available: 1 Preemption is not helpful for scheduling..
...
```

Final state of the `other-kuiperbelt` is `Started`

`kubectl get deployment,pod -A -l 'app in (other-kuiperbelt, small-oortcloud-tolerant,large-oortcloud-tolerant)'`{{exec}}

```text
NAMESPACE    NAME                                       READY   UP-TO-DATE   AVAILABLE   AGE
kuiperbelt   deployment.apps/other-kuiperbelt           1/1     1            1           35m
oortcloud    deployment.apps/large-oortcloud-tolerant   0/1     1            0           7m44s
oortcloud    deployment.apps/small-oortcloud-tolerant   0/1     1            0           26m

NAMESPACE    NAME                                            READY   STATUS    RESTARTS   AGE
kuiperbelt   pod/other-kuiperbelt-7c596d75bf-nxg4c           1/1     Running   0          4m49s
oortcloud    pod/large-oortcloud-tolerant-57c74d458c-nljr8   0/1     Pending   0          4m41s
oortcloud    pod/small-oortcloud-tolerant-6546b85b4d-58mwn   0/1     Pending   0          4m36s
```

Yes, only the `other-kuiperbelt` is now up and running.
