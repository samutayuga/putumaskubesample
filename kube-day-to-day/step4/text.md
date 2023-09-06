# Helm
Team `mercury` asked you to perform some operations using Helm, all in Namespace mercury:

Delete release `internal-issue-report-apiv1`
Upgrade release `internal-issue-report-apiv2` to any newer version of chart `bitnami/nginx` available
Install a new release `internal-issue-report-apache` of chart `bitnami/apache`. 
The Deployment should have two replicas, set these via Helm-values during install
There seems to be a broken release, stuck in pending-install state. Find it and delete it