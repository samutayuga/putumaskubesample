# Persistence Volume Claim StorageClass

Team Moonpie, which has the Namespace moon, needs more storage. 
Create a new `PersistentVolumeClaim` named `moon-pvc-126` in that namespace. 
This claim should use a new StorageClass `moon-retain` 
with the provisioner set to moon-retainer and the `reclaimPolicy` 
set to `Retain`. The claim should request storage of `3Gi`,
an accessMode of `ReadWriteOnce` and should use the new `StorageClass`.

The provisioner `moon-retainer` will be created by another team, 
so it's expected that the PVC will not boot yet. 
Confirm this by writing the log message from the PVC into file /opt/course/13/pvc-126-reason.