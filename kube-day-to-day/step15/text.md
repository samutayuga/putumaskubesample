# Pod missconfiguration

Team Moonpie has a nginx server Deployment called `web-moon` in Namespace `moon`. Someone started configuring it but it was never completed. To complete please create a ConfigMap called `configmap-web-moon-html` containing the content of file /opt/course/15/web-moon.html under the data key-name index.html.

The Deployment web-moon is already configured to work with this ConfigMap and serve its content. Test the nginx configuration for example using curl from a temporary nginx:alpine Pod.