# Lets taints the node

Inpect what nodes are there

```shell
kubectl get nodes
```

The following is to taint the node.

The format is, `key=value:effect`

```shell
kubectl taint node controlplane PodSize=SMALL:NoSchedule
```

Verify node and label are applied properly

```shell
kubectl describe node controlplane |grep "Taints:"
```
