# Validate if the pod with the same rule still schedule in node with label compute=MEDIUM

## Step

Check the inital state of the deployment for `oortcloud` and `kuiperbelt` related pod and deployment

`kubectl get deployment,pod -A -l 'app in (any-kuiperbelt, small-oortcloud-tolerant)'`{{exec}}

```text
NAME                                      READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/other-non-tolerant        0/1     1            0           23m
deployment.apps/small-oortcloud-tolerant   1/1     1            1           6m6s

NAME                                           READY   STATUS    RESTARTS   AGE
pod/other-non-tolerant-9c8544db6-gw7ls         0/1     Pending   0          23m
pod/small-oortcloud-tolerant-6cd8855b7f-zm2x9   1/1     Running   0          5m8s
```

With one pod in `Pending` and one in `Running`, it represents the pod that is accepted and not accepted by the node. Lets change node label to `compute=MEDIUM`

`kubectl label node controlplane compute=MEDIUM --overwrite`{{exec}}

Check if the node label has changed.

`kubectl describe node controlplane |grep -A 7  "Labels:"|grep "compute="`{{exec}}

```text
controlplane $ kubectl describe node controlplane |grep -A 7  "Labels:"|grep "compute="
                    compute=MEDIUM
...
```

Scale down then scale up the `small-oortcloud-tolerant` deployment for the new node label takes effect on pod scheduling,

```
kubectl scale deployment -n oortcloud small-oortcloud-tolerant --replicas 0
kubectl scale deployment -n oortcloud small-oortcloud-tolerant --replicas 1
```{{exec}}

## Verify

Inspect the warning entry, try to extract the event object and output it into `go-template`

`kubectl get events -n oortcloud -o go-template='{{ range .items }}{{ .involvedObject.kind}}{{"/"}}{{.involvedObject.name}}{{"\t"}}{{.message}}{{"\n"}}{{end}}' |grep Pod`{{exec}}

Example output,

```text
Pod/small-oortcloud-tolerant-6546b85b4d-rsrsk   Successfully assigned oortcloud/small-oortcloud-tolerant-6546b85b4d-rsrsk to controlplane
...
```

Verify if the rollout is successfull

`kubectl rollout status deployment small-oortcloud-tolerant -n oortcloud`{{exec}}

The result is,

```text
deployment "small-oortcloud-tolerant" successfully rolled out
```

The oortcloud namespace now has one deployment in pending and one in running state same as before.

`kubectl get deployment,pod -A -l 'app in (any-kuiperbelt, small-oortcloud-tolerant)'`{{exec}}

```text
controlplane $ kubectl get deployment,pod -A -l 'app in (any-kuiperbelt, small-oortcloud-tolerant)'
NAMESPACE    NAME                                       READY   UP-TO-DATE   AVAILABLE   AGE
kuiperbelt   deployment.apps/any-kuiperbelt             0/1     1            0           9m36s
oortcloud    deployment.apps/small-oortcloud-tolerant   1/1     1            1           6m33s

NAMESPACE    NAME                                            READY   STATUS    RESTARTS   AGE
kuiperbelt   pod/any-kuiperbelt-7bc984dc5c-hrm7p             0/1     Pending   0          9m36s
oortcloud    pod/small-oortcloud-tolerant-6546b85b4d-xlwdl   1/1     Running   0          67s
```
