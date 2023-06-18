# Prerequistes

Create namespaces

`kubectl create namespace magellan`{{exec}}

Create the configmap from a file

**prepare file**

```
cat  << EOF > app-config.yaml
port: 5115
endPoints:
- name: google
  url: https://www.google.com
- name: frontend
  url: http://frontend.magellan.svc.cluster.local:8080/ping
- name: backend
  url: http://backend.magellan.svc.cluster.local:8081/ping
- name: storage 
  url: http://storage.magellan.svc.cluster.local:8082/ping
EOF
```{{exec}}

That command creates a yaml file, `app-config.yaml`

**create config map**

`kubectl create configmap app-cm --from-file=app-config.yaml -n magellan`{{exec}}


## Create a secrets for docker registry
```shell
kubectl create secret docker-registry samutup-secrets \
--docker-server=https://hub.docker.com \
--docker-username='$(value DOCKER_REGISTRY_USER)' \
--docker-password='$(value DOCKER_REGISTRY_PASS)' \
--docker-email='$(value EMAIL)' \
--namespace magellan \
--output yaml --dry-run=client | kubectl apply -f -
```{{exec}}

## Create a service account that holds the `imagePullSecrets`

```shell
kubectl create serviceaccount netpol-sa -n magellan
```{{exec}}

`Patch the service account to link it to the imagePullSecrets`

```shell
kubectl patch serviceaccount -n magellan netpol-sa \
-p "{\"imagePullSecrets\": [{\"name\": \"samutup-secrets\" }] }"
```{{exec}}




