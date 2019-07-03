# ilivalidator-web-service

## First install in an Openshift Environment

The necessary components of the application are configured with the following steps
```
oc create -f 1_poddisruptionbudget.yaml
oc process -f 2_zk.yaml | oc apply -f-
oc process -p ENV="test" -p SOLR_JAVA_MEM="-Xms1024m -Xmx1024m" -p MEMORY_LIMIT="2048M" -p CPU_LIMIT="200m" -p MEMORY_REQUEST="2048M" -p CPU_REQUEST="200m" -p LOGGING_LEVEL="INFO" -f 3_statefulset_solr.yaml | oc apply -f-
oc create -f 4_poddisruptionbudget_solr.yaml
oc process -p ENV="test" -f 5_service-headless-solr.yaml | oc apply -f-
```
Anschliessend von der Konsole in einen solr Pod einloggen
```
oc rsh podname /bin/bash
```
Von hier aus die config auf Zookeeper hochladen. zk.solr-cloud-test.svc ist dabei die Adresse des entsprechenden Zookeeper Services
```
/opt/solr/server/scripts/cloud-scripts/zkcli.sh -z zookeeper.solr-cloud-test.svc:2181 -cmd upconfig -confdir /opt/solr/server/solr/configsets/_default/conf/ -confname gdi
```
Es sollte etwas in der Art
```
INFO  - 2019-06-25 17:34:40.825; org.apache.solr.common.cloud.ConnectionManager; zkClient has connected
```
erscheinen
### Collection erstellen mit 2 solr Pods (solr-headless-solr-cloud-integration.dev.so.ch ist zu ersetzen mit der Url der Solr Cloud)
```
curl "http://solr-headless-solr-cloud-test.dev.so.ch/solr/admin/collections?action=CREATE&name=gdi&numShards=1&replicationFactor=2"
```
Sollte etwas in der Art 
```
{
  "responseHeader":{
    "status":0,
    "QTime":29875},
  "success":{
    "solr-0.solr-headless:8983_solr":{
      "responseHeader":{
        "status":0,
        "QTime":28490},
      "core":"gdi_shard1_replica_n1"},
    "solr-1.solr-headless:8983_solr":{
      "responseHeader":{
        "status":0,
        "QTime":29088},
      "core":"gdi_shard1_replica_n2"}},
  "warning":"Using _default configset. Data driven schema functionality is enabled by default, which is NOT RECOMMENDED for production use. To turn it off: curl http://{host:port}/solr/gdi/config -d '{\"set-user-property\": {\"update.autoCreateFields\":\"false\"}}'"}
```
zurückliefern

### Dokument mit id dummy hinzufügen. Url auf Umgebung anpassen
```
curl -X POST -H 'Content-Type: application/json' 'http://solr-headless-solr-cloud-test.dev.so.ch/solr/gdi/update/json/docs?commit=true' --data-binary '{ "id": "dummy" }'
```
Sollte etwas in der Art
```
{
  "responseHeader":{
    "rf":2,
    "status":0,
    "QTime":8133}}
```
zurückliefern

### Liveness Probe anpassen
```
oc patch statefulset/solr -p '{"spec":{"template":{"spec":{"containers":[{"name":"solr","livenessProbe":{"httpGet":{"path":"http://solr-headless-solr-cloud-test.dev.so.ch/solr/gdi/select?q=id%3Adummy&rows=1","port":"80"}}}]}}}}'
```
Anschliessend beide solr Pods deleten
### Readiness Probe anpassen
```
oc patch statefulset/solr -p '{"spec":{"template":{"spec":{"containers":[{"name":"solr","readinessProbe":{"httpGet":{"path":"http://solr-headless-solr-cloud-test.dev.so.ch/solr/gdi/select?q=id%3Adummy&rows=1","port":"80"}}}]}}}}'
```
Anschliessend zunächst den solr-1 Pod deleten, warten bis er wieder läuft und dann den solr-0 Pod deleten.

## Update of app configuration in Openshift Environment

Make changes to the configuration in the template ilivalidator-web-service.yaml and run
Set environment and desirde version of the image
```
oc process -p env=test -p version=latest -f ilivalidator-web-service.yaml  | oc apply -f-
```
