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

`kubectl get events -n magellan -o go-template='{{ range $k,$v := .items }}{{ .involvedObject.kind}}{{"/"}}{{.involvedObject.name}}{{"\t"}}{{ .reportingInstance }}{{"\t"}}{{ .source.component}}{{"\t"}}{{ .reason}}{{"\n"}}{{end}}'`

Example output,

```text
Pod/oot-cloud-small-tolerant            default-scheduler       FailedScheduling
Pod/oot-cloud-small-tolerant            default-scheduler       FailedScheduling
Pod/small-ootcloud-tolerant             default-scheduler       Scheduled
Pod/small-ootcloud-tolerant             kubelet Pulling
Pod/small-ootcloud-tolerant             kubelet Pulled
Pod/small-ootcloud-tolerant             kubelet Created
Pod/small-ootcloud-tolerant             kubelet Started
```
