# Prerequistes

Inpect what nodes are there
```
kubectl get nodes
```{{exec}}
```

The node need to be tainted and labelled as well.
The taint determines on the pod which is owned by ootcloud will be accepted.
In taint notion, it is written as below,

`kubectl taint node controlplane owner=ootcloud:NoSchedule`

Whereas the label determines which node the pod can go. The pod which is its nodeSelector or noteAffinity match the node's label will go to that node.
So label is about the pod wants to be in which node. Lets this node is for the pod with low to medium computing power.

`kubectl label node controlplane podSize=SMALL`

Verify if taint and label applied on node properly,

`kubectl describe node controlplane`
