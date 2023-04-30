# A deployment with the non tolerant pod will not be able to rollout

## Step

Create namespace

`kubectl create namespace magellan`{{exec}}

Create a deployment `other-non-tolerant` in `magellan` namespace with `nginx:alpine` image.

`kubectl create deployment other-non-tolerant --image=nginx:alpine -n magellan`{{exec}}

## Verify the result

Verify if the scheduling is failed, by extracting events inside the namespace `magellan`. Get necessary columns from the event object and output it into `go-template`

`kubectl get events -n magellan -o go-template='{{ range $k,$v := .items }}{{ .involvedObject.kind}}{{"/"}}{{.involvedObject.name}}{{"\t"}}{{.message}}{{"\n"}}{{end}}' |grep Pod`{{exec}}

Example output,

```text
Pod/other-non-tolerant-9c8544db6-gw7ls  0/1 nodes are available: 1 node(s) had untolerated taint {owner: ootcloud}. preemption: 0/1 nodes are available: 1 Preemption is not helpful for scheduling..

```

The deployment rollout is failed

`kubectl rollout status deployment other-non-tolerant -n magellan`{{exec}}

The result is,

```text
Waiting for deployment "other-non-tolerant" rollout to finish: 0 of 1 updated replicas are available...
```

Check the pod and deployment in magellan namespace

`kubectl get deployment,pod -n magellan`{{exec}}

```text
NAME                                      READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/other-non-tolerant        0/1     1            0           2m9s
deployment.apps/small-ootcloud-tolerant   1/1     1            1           73s

NAME                                           READY   STATUS    RESTARTS   AGE
pod/other-non-tolerant-9c8544db6-ffl55         0/1     Pending   0          2m9s
pod/small-ootcloud-tolerant-6cd8855b7f-msww4   1/1     Running   0          73s
```
