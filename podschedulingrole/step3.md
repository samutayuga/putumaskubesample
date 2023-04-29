# Create the tolerant pod

Leave the non-torelant pod in `Pending`.

Create a pod in `magellan` namespace with `nginx:alpine` image and make it tolerant to `controlplane` node which its taint  is `PodSize=SMALL:NoSchedule`

Save the manifest into a file `/tmp/tolerant.yaml`

The corresponding imperative command for that is,

```shell
kubectl run tolerant --image=nginx:alpine --overrides '{"spec": {"tolerations": [ { "key": "PodSize", "operator": "Equal", "value": "SMALL", "effect": "NoSchedule" } ] } }' -n magellan --dry-run=client -o yaml > /tmp/tolerant.yaml

```

Observe the events inside the namespace `magellan`

```shell
kubectl get events -n magellan -o wide
```

Inspect the warning entry. Pay attention on, `OBJECT`, `SUBOBJECT`, `SOURCE` columns.
Make sure its values are, `pod`, `no-toleran` and `*-scheduler*` respectivelly.

>Try to extract the event object and output it into to-template
`k get events -n magellan -o go-template='{{ range $k,$v := .items }}{{ .involvedObject.kind}}{{"/"}}{{.involvedObject.name}}{{"\t"}}{{ .reportingInstance }}{{"\t"}}{{ .source.component}}{{"\t"}}{{ .reason}}{{"\n"}}{{end}}'`

Example output,

```text
Pod/no-tolerant default-scheduler-controlplane  <no value>      FailedScheduling
Pod/tolerant    default-scheduler-controlplane  <no value>      Scheduled
Pod/tolerant            kubelet Pulling
Pod/tolerant            kubelet Pulled
Pod/tolerant            kubelet Created
Pod/tolerant            kubelet Started
```
