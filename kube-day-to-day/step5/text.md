# Secrets and Service Account

## Prerequisite

`mkdir -p /opt/course/5`{{exec}}

`kubectl create namespace neptune`{{exec}}

* Create service account

`kubectl create serviceaccount neptune-sa-v2 -n neptune`{{exec}}

```shell
kubectl apply -n neptune -f - <<EOF
kind: Secret
apiVersion: v1
type: kubernetes.io/service-account-token
metadata:
  name: secret-new
  annotations:
    kubernetes.io/service-account.name: neptune-sa-v2
EOF
```{{exec}}

```shell
kubectl apply -n neptune -f - <<EOF
kind: Secret
apiVersion: v1
metadata:
  name: secret-v2
EOF
```{{exec}}

## Scenario
Team Neptune has its own ServiceAccount named `neptune-sa-v2` in Namespace `neptune`. A coworker needs the token from the Secret that belongs to that ServiceAccount. Write the base64 decoded token to file `/opt/course/5/token`.