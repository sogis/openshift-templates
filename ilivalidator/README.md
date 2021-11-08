# ilivalidator-web-service

## First install in an Openshift Environment
Checkout the openshift-templates repository:
```
git clone https://github.com/sogis/openshift-templates.git
cd openshift-templates
```
Create the following secret YAML file locally, in a directory outside the checked out Git repository. Replace the `xy` placeholders with the
appropriate keepass values. Then, in each environment (test, integration, production) create the secrets by running
```
oc create -n PROJECTNAME -f FILENAME
```
aws-secret-ilivalidator.yaml
```
apiVersion: v1
kind: Secret
metadata:
  name: aws-secret-ilivalidator
  labels:
    app: ilivalidator
type: Opaque
stringData:
  AWS_ACCESS_KEY_ID: xy
  AWS_SECRET_ACCESS_KEY: xy
```
All other necessary components of the application are configured in the template ilivalidator-web-service.yaml
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
oc process -p env=integration -p version=1.3.106 \
  -p CPU_LIMIT="1000m" \
  -p MEMORY_LIMIT="2Gi" \
  -p CPU_REQUEST="500m" \
  -p MEMORY_REQUEST="400Mi" \
  -f ilivalidator-web-service.yaml  \
   | oc apply -f-
```
```
oc process -p env=production -p version=1.3.106 \
  -p CPU_LIMIT="1000m" \
  -p MEMORY_LIMIT="2Gi" \
  -p CPU_REQUEST="500m" \
  -p MEMORY_REQUEST="2Gi" \
  -f ilivalidator-web-service.yaml  \
   | oc apply -f-
```
## Update of app configuration in Openshift Environment

Make changes to the configuration in the template ilivalidator-web-service.yaml and run
Set environment and desirde version of the image
```
oc process -p env=test -p version=latest -f ilivalidator-web-service.yaml  | oc apply -f-
```
