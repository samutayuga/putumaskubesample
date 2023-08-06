# Service: ClusterIP

Team Pluto needs a new cluster internal Service. Create a ClusterIP Service named `project-plt-6cc-svc` in Namespace pluto. This Service should expose a single Pod named `project-plt-6cc-api` of `nginx:1.17.3-alpine`, create that Pod as well. The Pod should be identified by label `project: plt-6cc-api`. The Service should use tcp port redirection of `3333:80`.

Finally use for example curl from a temporary nginx:alpine Pod to get the response from the Service. Write the response into `/opt/course/10/service_test.html`. Also check if the logs of Pod project-plt-6cc-api show the request and write those into `/opt/course/10/service_test.log`.