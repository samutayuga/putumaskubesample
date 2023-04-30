# Validate if the pod with the same rule is no longer schedule in node with podSize=LARGE

We have observed that the pod from ootcloud is able to sechedule either in node with `podSize=SMALL` or in node with `podSize=MEDIUM`. Verify by listing pod and deployment in magellan namespace,

`kubectl get deployment,pod -n magellan`{{exec}}

```text
NAME                                      READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/other-non-tolerant        0/1     1            0           39m
deployment.apps/small-ootcloud-tolerant   1/1     1            1           22m

NAME                                           READY   STATUS    RESTARTS   AGE
pod/other-non-tolerant-9c8544db6-k7mk8         0/1     Pending   0          39m
pod/small-ootcloud-tolerant-5b56889bd5-4dgg4   1/1     Running   0          8m50s
```

Lets assume there is only a node for ETL job which has the label, `podSize=LARGE`.
Change the label for the node,

`kubectl label node controlplane podSize=LARGE --overwrite`{{exec}}

Check if the node label has changed.

`kubectl describe node controlplane |grep -A 7  "Labels:"`{{exec}}

```text
Name:               controlplane
Labels:             beta.kubernetes.io/arch=amd64
                    ....
                    podSize=LARGE

```

Scale down `small-ootcloud-tolerant` deployment then scale up

```
kubectl scale deployment -n magellan small-ootcloud-tolerant --replicas 0
kubectl scale deployment -n magellan small-ootcloud-tolerant --replicas 1
```{{exec}}

This will trigger pod redeployment

Inspect the warning entry, try to extract the event object and output it into to-template

`kubectl get events -n magellan -o go-template='{{ range $k,$v := .items }}{{ .involvedObject.kind}}{{"/"}}{{.involvedObject.name}}{{"\t"}}{{.message}}{{"\n"}}{{end}}' |grep Pod`{{exec}}

Example output,

```text
Pod/other-non-tolerant-9c8544db6-gw7ls  0/1 nodes are available: 1 node(s) had untolerated taint {owner: ootcloud}. preemption: 0/1 nodes are available: 1 Preemption is not helpful for scheduling..
Pod/small-ootcloud-tolerant-6b44df898d-jr9vj    0/1 nodes are available: 1 node(s) didn't match Pod's node affinity/selector. preemption: 0/1 nodes are available: 1 Preemption is not helpful for scheduling..
...
Pod/small-ootcloud-tolerant-6cd8855b7f-5cr2b    Successfully assigned magellan/small-ootcloud-tolerant-6cd8855b7f-5cr2b to controlplane
...
Pod/small-ootcloud-tolerant-6cd8855b7f-r7zt5    0/1 nodes are available: 1 node(s) didn't match Pod's node affinity/selector. preemption: 0/1 nodes are available: 1 Preemption is not helpful for scheduling..
Pod/small-ootcloud-tolerant-6cd8855b7f-zm2x9    Successfully assigned magellan/small-ootcloud-tolerant-6cd8855b7f-zm2x9 to controlplane
...
```

At line says, the `Pod/small-ootcloud-tolerant-6cd8855b7f-r7zt5` if failed due to the `affinity` mismatch.

Verify if the rollout is pending

`kubectl rollout status deployment small-ootcloud-tolerant -n magellan`{{exec}}

The result is,

```text
Waiting for deployment "small-ootcloud-tolerant" rollout to finish: 0 of 1 updated replicas are available...
```

Now the deployment and pods are in pending

```text
NAME                                      READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/other-non-tolerant        0/1     1            0           42m
deployment.apps/small-ootcloud-tolerant   0/1     1            0           24m

NAME                                           READY   STATUS    RESTARTS   AGE
pod/other-non-tolerant-9c8544db6-gw7ls         0/1     Pending   0          42m
pod/small-ootcloud-tolerant-6cd8855b7f-r7zt5   0/1     Pending   0          4m30s
```
