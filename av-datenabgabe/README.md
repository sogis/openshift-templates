# Install or Update AV-Datenabgabe in OpenShift

Checkout the openshift-templates repository:

```
git clone https://github.com/sogis/openshift-templates.git
cd openshift-templates
```

Or, if already checked out: Update the OpenShift templates repository:

```
cd openshift-templates
git pull
```

Deploy test environment (for the test environment, the default values are mostly fine):

```
oc process -f av-datenabgabe/av-datenabgabe.yaml \
  -p HOSTNAME=av-datenabgabe-t.dev.so.ch \
  | oc apply -f -
```

Deploy production environment:

```
oc process -f av-datenabgabe/av-datenabgabe.yaml \
  -p ENVIRONMENT=production \
  -p ENVIRONMENT_SHORT=prod \
  -p TAG=1.0.5 \
  -p IMPORT_POLICY_SCHEDULED=false \
  -p REPLICA_COUNT=2 \
  -p HOSTNAME=av-datenabgabe.dev.so.ch \
  | oc apply -f -
```
