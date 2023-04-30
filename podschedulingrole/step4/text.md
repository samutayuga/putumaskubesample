# Validate if the pod with the same rule still schedule in node with podSize=MEDIUM

Check the inital state of the deployment in `magellan` namespace

`kubectl get deployment,pod -n magellan`{{exec}}

```text
NAME                                      READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/other-non-tolerant        0/1     1            0           39m
deployment.apps/small-ootcloud-tolerant   1/1     1            1           22m

NAME                                           READY   STATUS    RESTARTS   AGE
pod/other-non-tolerant-9c8544db6-k7mk8         0/1     Pending   0          39m
pod/small-ootcloud-tolerant-5b56889bd5-4dgg4   1/1     Running   0          8m50s
```

With one pod in `Pending` and one in `Running`, it represents the pod that is accepted and not accepted by the node. Lets change node label to `podSize=MEDIUM`

`kubectl label node controlplane podSize=MEDIUM --overwrite`{{exec}}

Check if the node label has changed.

`kubectl describe node controlplane`{{exec}}

```text
controlplane $ k describe node controlplane 
Name:               controlplane
Roles:              control-plane
Labels:             beta.kubernetes.io/arch=amd64
                    ...
                    podSize=MEDIUM
...
```

Rollout the `small-ootcloud-tolerant` deployment,

`kubectl rollout deployment restart -n magellan small-ootcloud-tolerant`{{exec}}

This will trigger pod redeployment

Inspect the warning entry, try to extract the event object and output it into to-template

`kubectl get events -n magellan -o go-template='{{ range $k,$v := .items }}{{ .involvedObject.kind}}{{"/"}}{{.involvedObject.name}}{{"\t"}}{{ .source.component}}{{"\t"}}{{ .reason}}{{"\t"}}{{.message}}{{"\n"}}{{end}}'`

Example output,

```text
Pod/other-non-tolerant-9c8544db6-k7mk8  default-scheduler       FailedScheduling        0/1 nodes are available: 1 node(s) had untolerated taint {owner: ootcloud}. preemption: 0/1 nodes are available: 1 Preemption is not helpful for scheduling..
...
Pod/small-ootcloud-tolerant-5b56889bd5-4dgg4    default-scheduler       Scheduled       Successfully assigned magellan/small-ootcloud-tolerant-5b56889bd5-4dgg4 to controlplane
...
Pod/small-ootcloud-tolerant-6cd8855b7f-tqlmn    default-scheduler       Scheduled       Successfully assigned magellan/small-ootcloud-tolerant-6cd8855b7f-tqlmn to controlplane
...
```

Verify if the rollout is successfull

`kubectl rollout status deployment small-ootcloud-tolerant -n magellan`{{exec}}

The result is,

```text
deployment "small-ootcloud-tolerant" successfully rolled out
```
