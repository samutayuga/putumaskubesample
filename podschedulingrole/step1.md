# Lets label and taints the nodes

Inpect what nodes are there

```shell
kubectl get nodes
```

```shell
kubectl label node controlplan size=SMALL
```

```shell
kubectl taints node PodSize=SMALL:NoSchedule
```