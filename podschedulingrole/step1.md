# Lets label and taints the nodes

Inpect what nodes are there

```shell
kubectl get nodes
```

The following is to label the node with `size=SMALL`

```shell
kubectl label node controlplan size=SMALL
```

The following is to taint the node.

The format is, `key=value:effect`

```shell
kubectl taint node PodSize=SMALL:NoSchedule
```

Verify node and label are applied properly

```shell
kubectl describe node controlplane |grep "Taints:"
```

```shell
kubectl describe node controlplane |grep "Labels:"
```
