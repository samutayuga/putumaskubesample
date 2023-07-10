# Job

## Prerequisite

`mkdir /opt/course/3`{{exec}}

`kubectl create namespace neptune`{{exec}}

## Scenario

Team Neptune needs a Job template located at `/opt/course/3/job.yaml`. This Job should run image `busybox:1.31.0` and execute sleep 2 && echo done. It should be in namespace neptune, run a total of 3 times and should execute 2 runs in parallel.

Start the Job and check its history. Each pod created by the Job should have the label `id: awesome-job`. The job should be named `neb-new-job` and the container `neb-new-job-container`.