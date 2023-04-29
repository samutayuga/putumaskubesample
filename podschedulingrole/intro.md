# Experiment the pod life cycle with the effect of node rule

The oot-cloud team own magellan namespace. The extending organization, requires the team only deploys their workload into current node. The organization cannot afford to have oot-cloud team to wrongly deploy their apps into other node that is not supposed to be.
At the same time, no apps from other team should be able to deploy the apps into oot-cloud team. The number of nodes that oot-cloud team belongs may be extended to very new future up to two three nodes. The same rules will apply to the new nodes. For the moment, oot-cloud team has only one node in the cluster, which is still sufficient with current traffic.

It implies few things,

* the node should have a taint that prevent other pods than those from oot-cloud to be scheduled.

* any pod from oot-team should be made tolerant to the taint of the node
