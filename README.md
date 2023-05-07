# putumaskubesample
`Pod Scheduling`

|Team|Pod Toleration and Node Affinity|Node|Status|
|-----|-----|----|-----|
|oortcloud|owner=oortcloud and compute in (SMALL or MEDIUM)|compute:SMALL,owner=oortcloud:NoSchedule|OK|
|oortcloud|owner=oortcloud and compute in (SMALL or MEDIUM)|compute:MEDIUM,owner=oortcloud:NoSchedule|OK|
|oortcloud|owner=oortcloud and compute in (LARGE)|compute:LARGE,owner=oortcloud:NoSchedule|OK|
|kuiperbelt|owner=kuiperbelt and compute exists|compute:ANY,owner=oortcloud:NoSchedule|OK|