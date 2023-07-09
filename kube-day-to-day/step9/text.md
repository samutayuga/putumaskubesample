# Deployment: Pod and Deployment

## Pre-request

In Namespace pluto there is single Pod named holy-api.

* Create namespace

`kubectl create namespace pluto`{{exec}}

* Create a directory

`mkdir -p /opt/course/9/holy-api-pod.yaml` {{exec}}

* Create a pod manifest

```shell
cat << EOF > /opt/course/9/holy-api-pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: holi-api
  namespace: pluto
  labels:
    app: holi-api
spec:
  containers:
  - image: nginx:alpine
    name: holi-api-container
    resources: {}
EOF
```
* Apply pod manifest

`kubectl apply -n pluto -f /opt/course/9/holy-api-pod.yaml`{{exec}}

## This is the scenario

It has been working okay for a while now, but Team Pluto needs it to be more reliable. Convert the Pod into a Deployment with 3 replicas and name holy-api. The raw Pod template file is available at /opt/course/9/holy-api-pod.yaml.

In addition, the new Deployment should set `allowPrivilegeEscalation: false` and `privileged: false` for the security context on container level.

Please create the Deployment and save its yaml under `/opt/course/9/holy-api-deployment.yaml`.