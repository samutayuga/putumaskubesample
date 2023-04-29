# Create the tolerant pod

Leave the `other-non-torelant` pod in `Pending`.

Create another pod in `magellan` namespace with `nginx:alpine` image and make it tolerant to `controlplane` node which its taint  is `owner=ootcloud:NoSchedule`. This represents the pod from ootcloud team.
Assuming it is a kind of standard apps with low computing capacity requirement.

```shell
kubectl run small-ootcloud-tolerant --image=nginx:alpine \
--overrides '{ "spec": { "tolerations": [ { "key": "owner","operator": "Equal", "value": "ootcloud", "effect": "NoSchedule" } ], "affinity": {"nodeAffinity": {"requiredDuringSchedulingIgnoredDuringExecution" : {"nodeSelectorTerms": [{"matchExpressions": [ {"key": "podSize", "operator": "In", "values": ["SMALL", "MEDIUM" ] } ] }] } }}  } }' \
-n magellan \
--dry-run=client \
-o yaml > /tmp/small-ootcloud-tolerant.yaml
```

Save the manifest into a file `/tmp/tolerant.yaml`

Observe the events inside the namespace `magellan`, try to extract the event object and output it into to-template

`kubectl get events -n magellan -o go-template='{{ range $k,$v := .items }}{{ .involvedObject.kind}}{{"/"}}{{.involvedObject.name}}{{"\t"}}{{ .source.component}}{{"\t"}}{{ .reason}}{{"\t"}}{{.message}}{{"\n"}}{{end}}'`

Example output,

```text
Pod/other-non-tolerant  default-scheduler       FailedScheduling        0/1 nodes are available: 1 node(s) had untolerated taint {owner: ootcloud}. preemption: 0/1 nodes are available: 1 Preemption is not helpful for scheduling..
Pod/small-ootcloud-tolerant     default-scheduler       Scheduled       Successfully assigned magellan/small-ootcloud-tolerant to controlplane
...
Pod/small-ootcloud-tolerant     kubelet Started Started container small-ootcloud-tolerant
```
