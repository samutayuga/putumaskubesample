# List of namespace

The DevOps team would like to get the list of all Namespaces in the cluster. Get the list and save it to /opt/course/1/namespaces.

```shell
mkdir -p /opt/course/1/namespaces

kubectl get namespaces > /opt/course/1/namespaces

cat /opt/course/1/namespaces
```{{exec}}

# Create `pod1` pod with docker image `httpd:2.4.41-alpine`. Name the container `pod1-container`. Create a script to get the pod status. Save the script in /opt/course/2/pod1-status-command.sh file

