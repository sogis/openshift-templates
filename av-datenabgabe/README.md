# Install or update AV-Datenabgabe in OpenShift

Create new project:

```
oc new-project agi-av-datenabgabe --display-name='AV-Datenabgabe'

oc policy add-role-to-user admin ...
```

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
