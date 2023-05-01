# Experiment the pod life cycle with the effect of node rule

The `ootcloud` team owns magellan namespace. Due to recent expansion of the team, the nodes occupation will need to regulate, as well. For instance, the team is only allowed to deploy their workload into its designated node.

The organization cannot afford to have `ootcloud` team to wrongly deploy their apps into other node that is not supposed to be.

At the same time, no apps from other team should be deployed into `ootcloud` team's designated node. In addition to this, the number of nodes that the team belongs to, may be extended to very near future, up to two or three. The same rules will apply to the new nodes. For the moment, the team has only one node in the cluster, which is still sufficient with current traffic.

It implies few things,

* the node should have a way to prevent other pods than those from ootcloud to be scheduled. This can be achieved through taint (on the node) and toleration (on the pod)

* no pod should go to the non tainted node. This can't be achieved by taint alone. It can be achieved by `nodeSelector` (on pod) and `label` (on node)

* supposed in the future, the team has 3 nodes. 2 nodes for normal app (low to medium computing capacity), 1 is for ETL job with high computing capacity. With this requirement in place, a pod can only go to either node 1 or node 2. The rest of the pod can go to node 3 only. This can be achieved by `nodeAffinity` with `nodeSelectorTerms`. Where its `matchExpressions` can accept the logical expression.

In this exercise we will walk through, the step to craft the pod manifest in different scenarios.

* deploy non tolerant pod to tainted node

* deploy the tolerant pod

* change the node taint so that become un-tolerant to the existing pod

* adapt the pod to be able to survive across different node's taint
