# Pod Status

## Prerequisite

`mkdir -p /opt/course/2`{{exec}}

## Scenario

Create a single Pod of image `httpd:2.4.41-alpine` in Namespace default. The Pod should be named pod1 and the container should be named `pod1-container`.

Your manager would like to run a command manually on occasion to output the status of that exact Pod. Please write a command that does this into `/opt/course/2/pod1-status-command.sh`. The command should use kubectl.