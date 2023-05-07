# putumaskubesample
`Pod Scheduling`

|Team|Pod Toleration and Node Affinity|Node|Status|
|-----|-----|----|-----|
|kuiperbelt|owner=kuiperbelt and compute exists|compute:MEDIUM,owner=oortcloud:NoSchedule |NOK|
|oortcloud|owner=oortcloud and compute in (SMALL or MEDIUM)|compute:SMALL,owner=oortcloud:NoSchedule|OK|
|oortcloud|owner=oortcloud and compute in (SMALL or MEDIUM)|compute:MEDIUM,owner=oortcloud:NoSchedule|OK|
|oortcloud|owner=oortcloud and compute in (SMALL or MEDIUM)|compute:LARGE,owner=oortcloud:NoSchedule|NOK|
|kuiperbelt|owner=kuiperbelt and compute exists|compute:ANY,owner=oortcloud:NoSchedule|OK|