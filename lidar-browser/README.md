# Install or update Lidar Browser in OpenShift

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
oc process -f lidar-browser/lidar-browser.yaml | oc apply -f -
```

Deploy integration environment:

```
oc project agi-apps-integration
oc process -f lidar-browser/lidar-browser.yaml \
  -p TAG=1.0.3 -p IMPORT_POLICY_SCHEDULED="false" -p REPLICA_COUNT="1" \
  | oc apply -f -
```

Deploy production environment:

```
oc project agi-apps-production
oc process -f lidar-browser/lidar-browser.yaml \
  -p TAG=1.0.3 -p IMPORT_POLICY_SCHEDULED="false" -p REPLICA_COUNT="2" \
  | oc apply -f -
```