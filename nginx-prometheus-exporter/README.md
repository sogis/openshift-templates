# Nginx Prometheus exporter

NGINX Prometheus exporter makes it possible to monitor NGINX or NGINX Plus using Prometheus.

## First install and update of app in an Openshift Environment

All necassary components of the application are configured in the template nginx-prometheus-exporter.yaml.
Set env parameter to set environment
Set version parameter to set Image version
```
oc process -f nginx-prometheus-exporter.yaml \
  -p APPNAME=nginx-prometheus-exporter \
  -p IMAGENAME=nginx/nginx-prometheus-exporter \ 
  -p TAG=0.8.0 \
  -p scheduled=false \
  -p env="gdi-test" \ 
  | oc apply -f-
```
