# Validate if the pod with the same rule is no longer schedule in node with compute=LARGE

We have observed that the pod from oortcloud is able to sechedule either in node with `compute=SMALL` or in node with `compute=MEDIUM`. Verify by listing pod and deployment in oortcloud namespace,

`kubectl get deployment,pod -n oortcloud`{{exec}}

```text
NAME                                      READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/other-non-tolerant        0/1     1            0           39m
deployment.apps/small-oortcloud-tolerant   1/1     1            1           22m

NAME                                           READY   STATUS    RESTARTS   AGE
pod/other-non-tolerant-9c8544db6-k7mk8         0/1     Pending   0          39m
pod/small-oortcloud-tolerant-5b56889bd5-4dgg4   1/1     Running   0          8m50s
```

Lets assume there is only a node for ETL job which has the label, `compute=LARGE`.
Change the label for the node,

`kubectl label node controlplane compute=LARGE --overwrite`{{exec}}

Check if the node label has changed.

`kubectl describe node controlplane |grep -A 7  "Labels:" | grep "compute="`{{exec}}

```text
Name:               controlplane
Labels:             beta.kubernetes.io/arch=amd64
                    ....
                    compute=LARGE

```

Scale down `small-oortcloud-tolerant` deployment then scale up

```
kubectl scale deployment -n oortcloud small-oortcloud-tolerant --replicas 0
kubectl scale deployment -n oortcloud small-oortcloud-tolerant --replicas 1
```{{exec}}

This will trigger pod redeployment

Inspect the warning entry, try to extract the event object and output it into to-template

`kubectl get events -n oortcloud -o go-template='{{ range .items }}{{ .involvedObject.kind}}{{"/"}}{{.involvedObject.name}}{{"\t"}}{{.message}}{{"\n"}}{{end}}' |grep Pod`{{exec}}

Example output,

```text
Pod/small-oortcloud-tolerant-6546b85b4d-pktrf   0/1 nodes are available: 1 node(s) didn't match Pod's node affinity/selector. preemption: 0/1 nodes are available: 1 Preemption is not helpful for scheduling..
...
```

At line says, the `Pod/small-oortcloud-tolerant-6cd8855b7f-r7zt5` if failed due to the `affinity` mismatch.

Verify if the rollout is pending

`kubectl rollout status deployment small-oortcloud-tolerant -n oortcloud`{{exec}}

The result is,

```text
Waiting for deployment "small-oortcloud-tolerant" rollout to finish: 0 of 1 updated replicas are available...
```

Now the deployment and pods are in pending

`kubectl get deployment,pod -A -l 'app in (any-kuiperbelt, small-oortcloud-tolerant)'`{{exec}}

```text
NAMESPACE    NAME                                       READY   UP-TO-DATE   AVAILABLE   AGE
kuiperbelt   deployment.apps/any-kuiperbelt             0/1     1            0           11m
oortcloud    deployment.apps/small-oortcloud-tolerant   0/1     1            0           8m56s

NAMESPACE    NAME                                            READY   STATUS    RESTARTS   AGE
kuiperbelt   pod/any-kuiperbelt-7bc984dc5c-hrm7p             0/1     Pending   0          11m
oortcloud    pod/small-oortcloud-tolerant-6546b85b4d-pktrf   0/1     Pending   0          51s
```
