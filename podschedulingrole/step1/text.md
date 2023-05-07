# Prerequistes

Inpect what nodes are there

`kubectl get nodes`{{exec}}

## taint

The node need to be tainted and labelled as well.
The taint determines which pods are accepted by the particular node. In this context, we will make sure that the node only accepts those those owned by oortcloud team.
In taint notion, it can be written as below,

`kubectl taint node controlplane owner=oortcloud:NoSchedule`{{exec}}

## label

Whereas the label, from the pod perspective, determines which node the it can go. The pod will be scheduled to the node with lable that match its `nodeSelector`.
So node's label is about the particular pod will be in which node. Lets this node is for the pod with low.

`kubectl label node controlplane compute=SMALL`{{exec}}

Verify if taint and label applied on node properly,

```
kubectl describe node controlplane |grep  "Taints:"
kubectl describe node controlplane |grep -A 7  "Labels:"|grep "compute="
```{{exec}}

Result is,

```text
controlplane $ kubectl describe node controlplane |grep  "Taints:"
Taints:             owner=oortcloud:NoSchedule
controlplane $ kubectl describe node controlplane |grep -A 7  "Labels:"|grep "compute="
                    compute=SMALL
```
