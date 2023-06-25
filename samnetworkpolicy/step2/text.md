# Create Frontend

# Create a deployment Frontend

```shell
kubectl create deployment frontend \
--image=samutup/http-ping:1.0.0 -n magellan \
-o yaml \
--dry-run=client > fe.yaml
```{{exec}}

Lets craft the deployment manifest for the following purpose,




`vim fe.yaml`{{exec}}

Mount the config map

Add `volumes` under `spec.template.spec`

```yaml
volumes:
- name: fe-v
  configMap:
    name: app-cm
    items:
    - key: app-config.yaml
      path: app-config.yaml
```

Add `volumeMounts` under `spec.template.spec.containers.volumeMounts`

```yaml
containers:
- image: ...
  volumeMounts:
  - name: fe-v
    mountPath: /app/config
```

Add `readinessProbe` under `spec.template.spec.containers`


```yaml
containers:
- image: ...
  readinessProbe:
    httpGet: 
      path: /ping
      port: 5115
    initialDelaySeconds: 5
    periodSeconds: 10
    failureThreshold: 5
    successThreshold: 1
```

Change the manifest, `spec.template.spec.serviceAccountName`  to use service account `netpol-sa`

```yaml
kind: Deployment
metadata:
  labels:
    app: frontend
  name: frontend
spec:
  replicas: 1
  ...
  template:
    metadata:
      labels:
        app: frontend
    spec:
      serviceAccountName: netpol-sa
      ...
```

Override Command and Args

```yaml
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
      serviceAccountName: netpol-sa
      containers:
      - image: samutup/http-ping:0.0.3
        name: http-ping
        command:
        - "/app/http-ping"
        args:
        - "-config=/app/config/app-config.yaml"
```

The `command` overwrites the DockerFile's `ENTRYPOINT`instruction.

With the command,
```shell
 docker inspect samutup/http-ping:1.0.0 |grep -A 4 "Entrypoint"
```
it will show,

```json
...
  "Entrypoint": [
                "/app/http-ping",
                "-config=/app/config/sam-ping.yaml"
            ],

```
In this scenario, we will demonstrate how the docker image's Entrypoint is overwritten by the `command` and `args` directive of pod manifest.
In this example, the command is following the entrypoint which executing the `/app/http-ping` binary while the arguments is ovwerwritten to, `-config=/app/config/app-config.yaml`. 

Another changes is to use the non root user to run the container which is managed under the `containers.securityContext` directive.

Lets verify that the Docker image itself allows the non user root to run the container.

```shell
 docker inspect samutup/http-ping:1.0.0 |grep "User"
```
it will show,

```json
...
 ...
"User": "appuser",

```
All right, it is showing the user is `appuser`

The changes for deployment manifest is as follow,

```yaml
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
      serviceAccountName: netpol-sa
      containers:
      - image: samutup/http-ping:0.0.3
        name: http-ping
        command:
        - "/app/http-ping"
        args:
        - "-config=/app/config/app-config.yaml"
        securityContext:
          allowPrivilegeEscalation: false
          runAsNonRoot: true
          runAsUser: 1000
          readOnlyRootFilesystem: true
...
```

In the end,

```shell
kubectl apply -n magellan -f - << EOF
apiVersion: apps/v1
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
      serviceAccountName: netpol-sa
      containers:
      - image: samutup/http-ping:0.0.3
        name: http-ping
        env:
        - name: APP_NAME
          value: Frontend
        command:
        - "/app/http-ping"
        args:
        - "-config=/app/config/app-config.yaml"
        securityContext:
          allowPrivilegeEscalation: false
          runAsNonRoot: true
          runAsUser: 1000
          readOnlyRootFilesystem: true
        resources: {}
        volumeMounts:
        - mountPath: /app/config
          name: fe-v
        readinessProbe:
          httpGet:
            path: /ping
            port: 5115
          periodSeconds: 10
          initialDelaySeconds: 5
          failureThreshold: 5
          successThreshold: 1
      volumes:
      - name: fe-v
        configMap:
          name: app-cm
          items:
          - key: app-config.yaml
            path: app-config.yaml
EOF
```{{exec}}

Verify if the deployment is working fine.


`k get all -n magellan -l app=frontend`{{exec}}


```shell
NAME                            READY   STATUS    RESTARTS   AGE
pod/frontend-86b7fb7dc7-gtb8z   1/1     Running   0          10m

NAME                       READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/frontend   1/1     1            1           10m

NAME                                  DESIRED   CURRENT   READY   AGE
replicaset.apps/frontend-86b7fb7dc7   1         1         1       10m
```
Expose the deployment into service,


`kubectl expose deployment -n magellan frontend --port 8080 --target-port 5115`{{exec}}

Verify if service created,

`k get all -n magellan -l app=frontend`{{exec}}

```shell
NAME                            READY   STATUS    RESTARTS   AGE
pod/frontend-86b7fb7dc7-gtb8z   1/1     Running   0          14m

NAME               TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE
service/frontend   ClusterIP   10.101.93.214   <none>        8080/TCP   35s

NAME                       READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/frontend   1/1     1            1           14m

NAME                                  DESIRED   CURRENT   READY   AGE
replicaset.apps/frontend-86b7fb7dc7   1         1         1       14m
```



