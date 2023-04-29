# Create non tolerant pod

Create namespace

`kubectl create namespace magellan`

## Non tolerant pod

This represents the pod that belongs to other team

Create a pod in `magellan` namespace with `nginx:alpine` image.

Save the manifest into a file `/tmp/other-non-tolerant.yaml`

```shell
kubectl run other-non-tolerant \
--image=nginx:alpine -n magellan \
--dry-run=client -o yaml > /tmp/other-non-tolerant.yaml

```

Observe the events inside the namespace `magellan` then try to extract the event object and output it into `go-template`

`kubectl get events -n magellan -o go-template='{{ range $k,$v := .items }}{{ .involvedObject.kind}}{{"/"}}{{.involvedObject.name}}{{"\t"}}{{ .source.component}}{{"\t"}}{{ .reason}}{{"\t"}}{{.message}}{{"\n"}}{{end}}'`

Example output,

```text
Pod/other-non-tolerant  default-scheduler       FailedScheduling        0/1 nodes are available: 1 node(s) had untolerated taint {owner: ootcloud}. preemption: 0/1 nodes are available: 1 Preemption is not helpful for scheduling..

```
