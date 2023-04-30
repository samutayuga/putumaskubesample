# Validate if the pod with the same rule still schedule in node with podSize=MEDIUM

With one pod in `Pending` and one in `Running`, it represents the pod that is accepted and not accepted by the node. Lets change node label to `podSize=MEDIUM`

`kubectl label node controlplane podSize=MEDIUM --overwrite`

Check if the node label has changed.

`kubectl describe node controlplane`

```text
controlplane $ k describe node controlplane 
Name:               controlplane
Roles:              control-plane
Labels:             beta.kubernetes.io/arch=amd64
                    ...
                    podSize=MEDIUM
...
```

Recreate the pod to target node with nodeSelector,

```shell
kubectl run small-ootcloud-tolerant --image=nginx:alpine \
--overrides '{ "spec": { "tolerations": [ { "key": "owner","operator": "Equal", "value": "ootcloud", "effect": "NoSchedule" } ], "affinity": {"nodeAffinity": {"requiredDuringSchedulingIgnoredDuringExecution" : {"nodeSelectorTerms": [{"matchExpressions": [ {"key": "podSize", "operator": "In", "values": ["SMALL", "MEDIUM" ] } ] }] } }}  } }' \
-n magellan \
--dry-run=client \
-o yaml > /tmp/small-ootcloud-tolerant.yaml 

```

Inspect the warning entry, try to extract the event object and output it into to-template

`kubectl get events -n magellan -o go-template='{{ range $k,$v := .items }}{{ .involvedObject.kind}}{{"/"}}{{.involvedObject.name}}{{"\t"}}{{ .source.component}}{{"\t"}}{{ .reason}}{{"\t"}}{{.message}}{{"\n"}}{{end}}'`

Example output,

```text
Pod/other-non-tolerant  default-scheduler       FailedScheduling        0/1 nodes are available: 1 node(s) had untolerated taint {owner: ootcloud}. preemption: 0/1 nodes are available: 1 Preemption is not helpful for scheduling..
Pod/small-ootcloud-tolerant     default-scheduler       Scheduled       Successfully assigned magellan/small-ootcloud-tolerant to controlplane
...
Pod/small-ootcloud-tolerant     kubelet Started Started container small-ootcloud-tolerant
Pod/small-ootcloud-tolerant     kubelet Killing Stopping container small-ootcloud-tolerant
Pod/small-ootcloud-tolerant     default-scheduler       Scheduled       Successfully assigned magellan/small-ootcloud-tolerant to controlplane
...
Pod/small-ootcloud-tolerant     kubelet Started Started container small-ootcloud-tolerant
```
