# Init Container

## Prequisites

`
mkdir -p /opt/course/17
kubetl create namespace mars
`{{exec}}



Last lunch you told your coworker from department Mars Inc how amazing InitContainers are. Now he would like to see one in action. There is a Deployment yaml at `/opt/course/17/test-init-container.yaml`. This Deployment spins up a single Pod of image `nginx:1.17.3-alpine` and serves files from a mounted volume, which is empty right now.

Create an InitContainer named `init-con` which also mounts that volume and creates a file `index.html` with content check this out! in the root of the mounted volume. For this test we ignore that it doesn't contain valid html.

The InitContainer should be using image busybox:1.31.0. Test your implementation for example using curl from a temporary nginx:alpine Pod.