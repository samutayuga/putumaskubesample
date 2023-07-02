# Create storage

Repeat the previous step for the storage,
Reuse the `secret`, `config map` and `service account`

`Create the deployment`

```shell
kubectl apply -n magellan -f - << EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: storage
  name: storage
spec:
  replicas: 1
  selector:
    matchLabels:
      app: storage
  strategy: {}
  template:
    metadata:
      labels:
        app: storage
    spec:
      serviceAccountName: netpol-sa
      containers:
      - image: samutup/http-ping:0.0.6
        name: http-ping
        env:
        - name: APP_NAME
          value: storage
        command:
        - "/app/http-ping"
        args:
        - "launchHttp"
        - "--appName=storage"
        - "--config=/app/config/app-config.yaml"
        securityContext:
          allowPrivilegeEscalation: false
          runAsNonRoot: true
          runAsUser: 1000
          readOnlyRootFilesystem: true
        resources: {}
        volumeMounts:
        - mountPath: /app/config
          name: storage-v
        readinessProbe:
          httpGet:
            path: /ping
            port: 5115
          periodSeconds: 10
          initialDelaySeconds: 5
          failureThreshold: 5
          successThreshold: 1
      volumes:
      - name: storage-v
        configMap:
          name: app-cm
          items:
          - key: app-config.yaml
            path: app-config.yaml
EOF
```{{exec}}

Verify if the deployment is working fine.


`k get all -n magellan -l app=storage`{{exec}}

Create a service

`kubectl expose deployment -n magellan storage --target-port 5115 --port=8082`{{exec}}


Verify


`kubectl get all -l app=storage -n magellan`{{exec}}





