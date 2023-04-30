# Validate if the pod with the same rule is no longer schedule in node with podSize=LARGE

We have observed that the pod from ootcloud is able to sechedule either in node with `podSize=SMALL` or in node with `podSize=MEDIUM`. Verify with the listing pod and deployment in magellan namespace,

`kubectl get deployment,pod -n magellan`{{exec}}

```text
NAME                                      READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/other-non-tolerant        0/1     1            0           39m
deployment.apps/small-ootcloud-tolerant   1/1     1            1           22m

NAME                                           READY   STATUS    RESTARTS   AGE
pod/other-non-tolerant-9c8544db6-k7mk8         0/1     Pending   0          39m
pod/small-ootcloud-tolerant-5b56889bd5-4dgg4   1/1     Running   0          8m50s


Lets assume there is only a node for ETL job which has the label, `podSize=LARGE`.
Change the label for the node,

`kubectl label node controlplane podSize=LARGE --overwrite`{{exec}}

Check if the node label has changed.

`kubectl describe node controlplane`

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

`kubectl get events -n magellan -o go-template='{{ range $k,$v := .items }}{{ .involvedObject.kind}}{{"/"}}{{.involvedObject.name}}{{"\t"}}{{ .source.component}}{{"\t"}}{{ .reason}}{{"\t"}}{{.message}}{{"\n"}}{{end}}'`

Example output,

```text
Pod/other-non-tolerant-9c8544db6-k7mk8  default-scheduler       FailedScheduling        0/1 nodes are available: 1 node(s) had untolerated taint {owner: ootcloud}. preemption: 0/1 nodes are available: 1 Preemption is not helpful for scheduling..
...
Pod/small-ootcloud-tolerant-5b56889bd5-4dgg4    default-scheduler       Scheduled       Successfully assigned magellan/small-ootcloud-tolerant-5b56889bd5-4dgg4 to controlplane
...
Pod/small-ootcloud-tolerant-6b44df898d-vw9cg    default-scheduler       FailedScheduling        0/1 nodes are available: 1 node(s) didn't match Pod's node affinity/selector. preemption: 0/1 nodes are available: 1 Preemption is not helpful for scheduling..
Pod/small-ootcloud-tolerant-6b44df898d-vw9cg    default-scheduler       FailedScheduling        skip schedule deleting pod: magellan/small-ootcloud-tolerant-6b44df898d-vw9cg
...
Pod/small-ootcloud-tolerant-6cd8855b7f-tqlmn    default-scheduler       Scheduled       Successfully assigned magellan/small-ootcloud-tolerant-6cd8855b7f-tqlmn to controlplane
...
```

Verify if the rollout is pending

`kubectl rollout status deployment small-ootcloud-tolerant -n magellan`{{exec}}

The result is,

```text
Waiting for deployment "small-ootcloud-tolerant" rollout to finish: 0 of 1 updated replicas are available...
```