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

```text
Pod/large-ootcloud-tolerant             default-scheduler       Scheduled
...
Pod/large-ootcloud-tolerant             kubelet Started
...
Pod/small-ootcloud-tolerant             default-scheduler       FailedScheduling
```

Final state of the `large-ootcloud-tolerant` is `Started`
