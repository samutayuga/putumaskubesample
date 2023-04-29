# Validate if the pod with the same rule is no longer schedule in node with podSize=LARGE

We have observed that the pod from ootcloud is able to sechedule either in node with `podSize=SMALL` or in node with `podSize=MEDIUM`. Lets assume there is a node for ETL job which has the label, `podSize=LARGE`.
Change the label for the node,

`kubectl label node controlplane podSize=LARGE --overwrite`

Check if the node label has changed.

`kubectl describe node controlplane`

```text
Name:               controlplane
Labels:             beta.kubernetes.io/arch=amd64
                    ....
                    podSize=LARGE

```

Recreate the pod, to see what its effects,

`kubectl delete pod -n magellen small-ootcloud-tolerant --force --grace-period 0`

`kubectl apply -f /tmp/small-ootcloud-tolerant.yaml`

Inspect the warning entry, try to extract the event object and output it into to-template

`kubectl get events -n magellan -o go-template='{{ range $k,$v := .items }}{{ .involvedObject.kind}}{{"/"}}{{.involvedObject.name}}{{"\t"}}{{ .reportingInstance }}{{"\t"}}{{ .source.component}}{{"\t"}}{{ .reason}}{{"\n"}}{{end}}'`

Example output,

```text
...
Pod/small-ootcloud-tolerant             default-scheduler       FailedScheduling
```

As expected it is failed to schedule, because the node is for pod with large computing requirement.
