# Create a deployment with non tolerant pod

Create namespace

`kubectl create namespace magellan`

Create a deployment `other-non-tolerant` in `magellan` namespace with `nginx:alpine` image.

```shell
kubectl create deployment other-non-tolerant \
--image=nginx:alpine -n magellan
```

Verify if the scheduling is failed, by extracting events inside the namespace `magellan`. Get necessary columns from the event object and output it into `go-template`

```
kubectl get events -n magellan -o go-template='{{ range $k,$v := .items }}{{ .involvedObject.kind}}{{"/"}}{{.involvedObject.name}}{{"\t"}}{{ .source.component}}{{"\t"}}{{ .reason}}{{"\t"}}{{.message}}{{"\n"}}{{end}}'

```

Example output,

```text
Pod/other-non-tolerant-9c8544db6-kpd7g  default-scheduler       FailedScheduling        0/1 nodes are available: 1 node(s) had untolerated taint {owner: ootcloud}. preemption: 0/1 nodes are available: 1 Preemption is not helpful for scheduling..
ReplicaSet/other-non-tolerant-9c8544db6 replicaset-controller   SuccessfulCreate        Created pod: other-non-tolerant-9c8544db6-kpd7g
Deployment/other-non-tolerant   deployment-controller   ScalingReplicaSet       Scaled up replica set other-non-tolerant-9c8544db6 to 1

```

The deployment rollout is failed

```
kubectl rollout status deployment other-non-tolerant -n magellan
```{{exec}}

The result is,
```text
Waiting for deployment "other-non-tolerant" rollout to finish: 0 of 1 updated replicas are available...
```