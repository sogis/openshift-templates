# Install or update AV-Datenabgabe in OpenShift

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

Deploy test environment (for the test environment, the default values of the template parameters are usually fine):

```
oc project agi-apps-test
oc process -f av-datenabgabe/av-datenabgabe.yaml | oc apply -f -
```

Deploy production environment:

```
oc project agi-apps-production
oc process -f av-datenabgabe/av-datenabgabe.yaml \
  -p ENVIRONMENT_SHORT=prod \
  -p TAG=1.0.5 \
  -p IMPORT_POLICY_SCHEDULED=false \
  -p REPLICA_COUNT=2 \
  | oc apply -f -
```
