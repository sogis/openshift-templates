# Install or update the embedded application in OpenShift

## Install or update the cadastre application

Checkout the openshift-templates repository:

```
git clone https://github.com/sogis/openshift-templates.git
cd openshift-templates
```

Or, if already checked out, update the OpenShift templates repository:

```
cd openshift-templates
git pull
```


Deploy test environment:
```
oc project agi-apps-test
oc process -f wgc-embedded/wgc-embedded.yaml \
  -p version=latest \
  -p env=test \
  -p CPU_LIMIT="500m" \
  -p MEMORY_LIMIT="512Mi" \
  -p CPU_REQUEST="250m" \
  -p MEMORY_REQUEST="258Mi" \
  | oc apply -f -
```
Deploy integration environment:
```
oc project agi-apps-integration
oc process -f wgc-embedded/wgc-embedded.yaml \
  -p version=latest \
  -p env=integration \
  -p CPU_LIMIT="500m" \
  -p MEMORY_LIMIT="512Mi" \
  -p CPU_REQUEST="250m" \
  -p MEMORY_REQUEST="258Mi" \
  | oc apply -f -
```
Deploy production environment:
```
oc project agi-apps-production
oc process -f wgc-embedded/wgc-embedded.yaml \
  -p version=production \
  -p env=test \
  -p CPU_LIMIT="500m" \
  -p MEMORY_LIMIT="512Mi" \
  -p CPU_REQUEST="250m" \
  -p MEMORY_REQUEST="258Mi" \
  | oc apply -f -
```
