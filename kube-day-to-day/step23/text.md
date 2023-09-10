# Resources

## Prerequisite

`kubectl create namespace pluto`{{exec}}

`kubectl config set-context --current --namespace pluto`{{exec}}

`mkdir -p /opt/course/p1`{{exec}}


```
echo /opt/course/p1/project-23-api.yaml << EOD
apiVersion: apps/v1
kind: Deployment
metadata:
  name: project-23-api
  namespace: pluto
spec:
  replicas: 3
  selector:
    matchLabels:
      app: project-23-api
  template:
    metadata:
      labels:
        app: project-23-api
    spec:
      volumes:
      - name: cache-volume1
        emptyDir: {}
      - name: cache-volume2
        emptyDir: {}
      - name: cache-volume3
        emptyDir: {}
      containers:
      - image: httpd:2.4-alpine
        name: httpd
        volumeMounts:
        - mountPath: /cache1
          name: cache-volume1
        - mountPath: /cache2
          name: cache-volume2
        - mountPath: /cache3
          name: cache-volume3
        env:
        - name: APP_ENV
          value: "prod"
        - name: APP_SECRET_N1
          value: "IO=a4L/XkRdvN8jM=Y+"
        - name: APP_SECRET_P1
          value: "-7PA0_Z]>{pwa43r)__"
EOD
```{{exec}}

`kubectl -f /opt/course/p1/project-23-api.yaml`

## Run Scenario

In Namespace pluto there is a Deployment named `project-23-api`. It has been working okay for a while but Team Pluto needs it to be more reliable. Implement a liveness-probe which checks the container to be reachable on port 80. Initially the probe should wait 10, periodically 15 seconds.

The original Deployment yaml is available at `/opt/course/p1/project-23-api.yaml`. Save your changes at `/opt/course/p1/project-23-api-new.yaml` and apply the changes.