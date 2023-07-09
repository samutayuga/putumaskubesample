# Docker: containerization

## Create the main.go file

`mkdir -p /opt/course/11/image`{{exec}}


```go
package main

import (
	"flag"
	"fmt"
	"log"
	"net/http"
)

var (
	appName string
	portNum int
)

func handle(rw http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(rw, "Hi there, here is %s", r.URL.Path[1:])
}
func init() {
	flag.StringVar(&appName, "appName", "CKAD", "-appName CKAD")
	flag.IntVar(&portNum, "portNum", 8080, "-portNum 8080")
	flag.Parse()
}

func main() {
	log.SetFlags(log.LstdFlags | log.Lshortfile)
	log.Printf("Welcome to %s, started at port %d\n", appName, portNum)
	http.HandleFunc("/", handle)

	log.Fatal(http.ListenAndServe(fmt.Sprintf(":%d", portNum), nil))
}
```

## Create Docker File

```
FROM golang:1.20-alpine AS builder
WORKDIR /app
COPY go.mod ./
#COPY go.sum ./
COPY main.go ./main.go



RUN go mod tidy
RUN go build -o /sample .
# Final Stage - Stage 2
FROM alpine:3.14.2 as baseImage

WORKDIR /app


COPY --from=builder /sample ./sample

RUN adduser -S appuser appuser
USER appuser

ENTRYPOINT ["/app/sample","-appName=sample","-portNum=8090"]
EXPOSE 8090
```

```
module samutup

go 1.20
```

During the last monthly meeting you mentioned your strong expertise in container technology. Now the Build&Release team of department Sun is in need of your insight knowledge. There are files to build a container image located at /opt/course/11/image. The container will run a Golang application which outputs information to stdout. You're asked to perform the following tasks:

NOTE: Make sure to run all commands as user k8s, for docker use sudo docker

Change the Dockerfile. The value of the environment variable SUN_CIPHER_ID should be set to the hardcoded value 5b9c1065-e39d-4a43-a04a-e59bcea3e03f
Build the image using Docker, named registry.killer.sh:5000/sun-cipher, tagged as latest and v1-docker, push these to the registry
Build the image using Podman, named registry.killer.sh:5000/sun-cipher, tagged as v1-podman, push it to the registry
Run a container using Podman, which keeps running in the background, named sun-cipher using image registry.killer.sh:5000/sun-cipher:v1-podman. Run the container from k8s@terminal and not root@terminal
Write the logs your container sun-cipher produced into /opt/course/11/logs. Then write a list of all running Podman containers into /opt/course/11/containers