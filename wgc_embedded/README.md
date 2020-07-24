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
  -p CPU_LIMIT="0" \
  -p MEMORY_LIMIT="512M" \
  -p CPU_REQUEST="0" \
  -p MEMORY_REQUEST="500k" \
  | oc apply -f -
```
