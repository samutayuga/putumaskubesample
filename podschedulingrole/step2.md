# Create non tolerant pod

Create namespace

```shell
kubectl create namespace magellan
```

Create a pod in `magellan` namespace with `nginx:alpine` image.

Save the manifest into a file `/tmp/no-tolerant.yaml`

```shell
kubectl run no-tolerant --image=nginx:alpine -n magellan --dry-run=client -o yaml > /tmp/no-tolerant.yaml

```

Once it is applied, observe if pod is stuck in `Pending`.

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

```
