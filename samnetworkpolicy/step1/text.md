# Prerequistes

Create namespaces

`kubectl create namesapce maggellan`{{exec}}

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

`kubectl create configmap fe-cm --from-file=app-config.yaml`{{exec}}

# Create a deployment backend

```shell
kubectl create deployment frontend \
--image=samutup/http-ping:0.0.1 -n magellan \
-o yaml 
--dry-run=client > fe.yaml
```{{exec}}

Lets craft the deployment manifest to mount the config map.


```shell
vim fe.yaml
```{{exec}}

## Add `volumes` under `spec.template.spec`
```yaml
volumes:
- name: fe-v
  configMap:
    name: fe-cm
    items:
    - key: http-ping.yaml
      path: http-ping.yaml
```

## Add `volumeMounts` under `spec.template.spec.volumeMounts`

```yaml
containers:
- image: ...
  volumeMounts:
  - name: fe-v
    mountPath: /app/config
```
## Add `readinessProbe` under `spec.template.spec.containers`


```yaml
containers:
- image: ...
  readinessProbe:
    httpGet: /ping
    port: 5115
  initialDelaySeconds: 5
  periodSeconds: 10
  failureThreshold: 5
  successThreshold: 1
```
In the end,

```shell
kubectl apply -f - apiVersion: apps/v1 << EOF
kind: Deployment
metadata:
  labels:
    app: frontend
  name: frontend
spec:
  replicas: 1
  selector:
    matchLabels:
      app: frontend
  strategy: {}
  template:
    metadata:
      labels:
        app: frontend
    spec:
      containers:
      - image: samutup/http-ping:0.0.1
        name: http-ping
        resources: {}
        volumeMounts:
        - mountPath: /app/config
          name: fe-cm
        readinessProbe:
          httpGet:
            path: /ping
            port: 5115
          periodSeconds: 10
          initialDelaySeconds: 5
          failureThreshold: 5
          successThreshold: 1
      volumes:
      - name: fe-cm
        configMap:
          name: app-config
          items:
          - key: sam-ping.yaml
            path: sam-ping.yaml
EOF
```{{exec}}




