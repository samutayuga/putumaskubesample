# Create backend

Repeat the previous step for the backend,
Reuse the `secret`, `config map` and `service account`

`Create the deployment`

```shell
kubectl apply -n magellan -f - << EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: backend
  name: backend
spec:
  replicas: 1
  selector:
    matchLabels:
      app: backend
  strategy: {}
  template:
    metadata:
      labels:
        app: backend
    spec:
      serviceAccountName: netpol-sa
      containers:
      - image: samutup/http-ping:0.0.1
        name: http-ping
        env:
        - name: APP_NAME
          value: backend
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
          name: be-v
        readinessProbe:
          httpGet:
            path: /ping
            port: 5115
          periodSeconds: 10
          initialDelaySeconds: 5
          failureThreshold: 5
          successThreshold: 1
      volumes:
      - name: be-v
        configMap:
          name: app-cm
          items:
          - key: app-config.yaml
            path: app-config.yaml
EOF
```{{exec}}

Create a service

`kubectl expose deployment -n magellan backend --target-port 5115 --port=8081`{{exec}}


Verify


`kubectl get all -l app=backend -n magellan`{{exec}}





