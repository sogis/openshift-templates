# ilivalidator-web-service

## First install in an Openshift Environment

All necessary components of the application are configured in the template ilivalidator-web-service.yaml
Set environment and desired version of the image for test,int and prod environment
```
oc process -p env=test -p version=latest \ 
  -p CPU_LIMIT="0" \
  -p MEMORY_LIMIT="0" \
  -p CPU_REQUEST="0" \
  -p MEMORY_REQUEST="0" \
  -f ilivalidator-web-service.yaml  \
  | oc apply -f-
```
```
oc process -p env=integration -p version=1.2.18 \ 
  -p CPU_LIMIT="800m" \
  -p MEMORY_LIMIT="800Mi" \
  -p CPU_REQUEST="40m" \
  -p MEMORY_REQUEST="400Mi" \
  -f ilivalidator-web-service.yaml  \
   | oc apply -f-
```
```
oc process -p env=production -p version=1.2.18 \ 
  -p CPU_LIMIT="800m" \
  -p MEMORY_LIMIT="800Mi" \
  -p CPU_REQUEST="40m" \
  -p MEMORY_REQUEST="800Mi" \
  -f ilivalidator-web-service.yaml  \
   | oc apply -f-
```
## Update of app configuration in Openshift Environment

Make changes to the configuration in the template ilivalidator-web-service.yaml and run
Set environment and desirde version of the image
```
oc process -p env=test -p version=latest -f ilivalidator-web-service.yaml  | oc apply -f-
```
