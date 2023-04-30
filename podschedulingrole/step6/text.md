# Validate if podSize=LARGE can schedule in the node

We have observed that the pod from ootcloud is able to sechedule either in node with `podSize=SMALL` or in node with `podSize=MEDIUM`, but not in the node with label, `podSize=LARGE`.

Lets create the new pod that really requires the LARGE node.

```shell
kubectl run large-ootcloud-tolerant --image=nginx:alpine \
--overrides '{ "spec": { "tolerations": [ { "key": "owner","operator": "Equal", "value": "ootcloud", "effect": "NoSchedule" } ], "affinity": {"nodeAffinity": {"requiredDuringSchedulingIgnoredDuringExecution" : {"nodeSelectorTerms": [{"matchExpressions": [ {"key": "podSize", "operator": "In", "values": ["LARGE" ] } ] }] } }}  } }' \
-n magellan \
--dry-run=client \
-o yaml > /tmp/large-ootcloud-tolerant.yaml 

```

then apply it,

`kubectl apply -f /tmp/large-ootcloud-tolerant.yaml`

Extact the events,

`kubectl get events -n magellan -o go-template='{{ range $k,$v := .items }}{{ .involvedObject.kind}}{{"/"}}{{.involvedObject.name}}{{"\t"}}{{ .source.component}}{{"\t"}}{{ .reason}}{{"\t"}}{{.message}}{{"\n"}}{{end}}'`

```text
Pod/large-ootcloud-tolerant     default-scheduler       Scheduled       Successfully assigned magellan/large-ootcloud-tolerant to controlplane
...
Pod/large-ootcloud-tolerant     kubelet Started Started container large-ootcloud-tolerant
Pod/other-non-tolerant  default-scheduler       FailedScheduling        0/1 nodes are available: 1 node(s) had untolerated taint {owner: ootcloud}. preemption: 0/1 nodes are available: 1 Preemption is not helpful for scheduling..
...
Pod/small-ootcloud-tolerant     kubelet Created Created container small-ootcloud-tolerant
Pod/small-ootcloud-tolerant     kubelet Started Started container small-ootcloud-tolerant
Pod/small-ootcloud-tolerant     kubelet Killing Stopping container small-ootcloud-tolerant
Pod/small-ootcloud-tolerant     default-scheduler       Scheduled       Successfully assigned magellan/small-ootcloud-tolerant to controlplane
Pod/small-ootcloud-tolerant     kubelet Pulled  Container image "nginx:alpine" already present on machine
Pod/small-ootcloud-tolerant     kubelet Created Created container small-ootcloud-tolerant
Pod/small-ootcloud-tolerant     kubelet Started Started container small-ootcloud-tolerant
Pod/small-ootcloud-tolerant     kubelet Killing Stopping container small-ootcloud-tolerant
Pod/small-ootcloud-tolerant     default-scheduler       FailedScheduling        0/1 nodes are available: 1 node(s) didn't match Pod's node affinity/selector. preemption: 0/1 nodes are available: 1 Preemption is not helpful for scheduling..
```

Final state of the `large-ootcloud-tolerant` is `Started`
