# Experiment the pod life cycle with the effect of node rule

The `oot-cloud` team owns magellan namespace. Due to recent expansion of the team, the nodes occupation will need to regulate, as well. For instance, the team is only allowed to deploy their workload into its designated node.

The organization cannot afford to have `oot-cloud` team to wrongly deploy their apps into other node that is not supposed to be.

At the same time, no apps from other team should be deployed into `oot-cloud` team's designated cluster. In addition to this, the number of nodes that the team belongs to, may be extended to very near future, up to two or three. The same rules will apply to the new nodes. For the moment, the team has only one node in the cluster, which is still sufficient with current traffic.

It implies few things,

* the node should have a taint that prevent other pods than those from oot-cloud to be scheduled.

* any pod from oot-team should be made tolerant to the taint of the node

* no pod should be assigned to non tainted node.

In this exercise we will walk through, the step to craft the pod manifest in different scenarios.

* deploy non tolerant pod to tainted node

* deploy the tolerant pod

* change the node taint so that become un-tolerant to the existing pod

* adapt the pod to be able to survive across different node's taint
