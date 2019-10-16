# Solr Cloud

## First install in an Openshift Environment

First create the necessary secret dbcredentials
Lokal eine Datei user.txt erstellen mit dem Usernamen sogis_service.
Ausserdem eine Datei password.txt mit dem Passwort des Users erstellen (im keepass)
Achtung die Dateien müssen genau so heissen.
Dann das Secret erstellen
```
oc create secret generic dbcredentials --from-file user.txt --from-file password.txt
```
The necessary components of the application are configured with the following steps
```
oc create -f 1_poddisruptionbudget.yaml
oc process -f 2_zk.yaml | oc apply -f-
oc process -p ENV="test" -p SOLR_JAVA_MEM="-Xms1024m -Xmx1024m" -p MEMORY_LIMIT="2048M" -p CPU_LIMIT="200m" -p MEMORY_REQUEST="2048M" -p CPU_REQUEST="200m" -p LOGGING_LEVEL="INFO" -p DBSERVER='geoweb-t.rootso.org' -f 3_statefulset_solr.yaml | oc apply -f-
oc create -f 4_poddisruptionbudget_solr.yaml
oc process -p ENV="test" -f 5_service-headless-solr.yaml | oc apply -f-
```
Je nach Umgebung muss darauf geachtet werden die Ressource Limits korrekt zu setzen. In der Testumgebung braucht es gar keine (nachträglich aus dem Statefulset entfernen), auf der Integration sollten die Requested Resources tiefer sein als die Limits auf der Produktion identisch. Nach Anpassung der Statefulsets müssen die Zookeeper Pods gelöscht werden. Die Solr Pods werden später ohenhin noch gelöscht.
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

### Dokument mit id dummy hinzufügen. (Bitte die Url auf Umgebung anpassen)
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
oc patch statefulset/solr -p '{"spec":{"template":{"spec":{"containers":[{"name":"solr","livenessProbe":{"httpGet":{"path":"/solr/gdi/select?q=id%3Adummy&rows=1","port":8983}}}]}}}}'
```
Anschliessend beide solr Pods deleten
### Readiness Probe anpassen
```
oc patch statefulset/solr -p '{"spec":{"template":{"spec":{"containers":[{"name":"solr","readinessProbe":{"httpGet":{"path":"/solr/gdi/select?q=id%3Adummy&rows=1","port":8983}}}]}}}}'
```
Anschliessend zunächst den solr-1 Pod deleten, warten bis er wieder läuft und dann den solr-0 Pod deleten.

### AGI Config hochladen
```
git clone https://github.com/sogis/searchservice.git
cd solr/configsets/
oc rsync gdi solr-0:/opt/solr/server/home
oc rsync gdi solr-1:/opt/solr/server/home
```
In einen solr Pod (solr-0 oder solr-1) einloggen und configset gdi updaten
```
oc rsh solr-0 /bin/bash
/opt/solr/server/scripts/cloud-scripts/zkcli.sh -z zookeeper.solr-cloud-test.svc:2181 -cmd upconfig -confdir /opt/solr/server/home/gdi/conf -confname gdi
```
### Update des gdi configsets
```
curl "http://solr-headless-solr-cloud-test.dev.so.ch/solr/admin/collections?action=MODIFYCOLLECTION&collection=gdi&collection.configName=gdi"
```

## Update of app configuration in Openshift Environment

tbd

## Update Dataimporthandler

Unter https://github.com/sogis/searchservice/solr/configsets/gdi/conf befinden sich die beiden für die Suche notwendigen Configfiles (DIH Files) dih_geodata_config.xml und dih_metadata_config.xml. dih_metadata ist für die Suche nach Kartenlayern und in deren Metadaten. dih_geodata für alle weiteren Objektsuchen. Wenn nun eine neue Suche hinzugefügt wird oder eine bestehende gelöscht werden soll muss man wie folgt vorgehen (Beispiel für die Testumgebung):

```
git clone https://github.com/sogis/searchservice
cd searchservice/solr/configsets/gdi/conf
```

Hinzufügen der entity im entsprechenden DIH File. Beispiel 
```
<entity name="ch_so_afu_abbaustellen_abbaustellen" query="SELECT * FROM afu_abbaustellen_pub.abbaustelle_solr_v">
</entity>
```

Anzupassen sind hier im Tag *\<entity\>* *name* und *query*. *name* ist der Facet Name aus dem Eintrag im AGDI unter Dataset/Solr Facet, wobei die Punkte durch Unterstriche ersetzt werden müssen. Query frägt den für die Suche erstellten View ab.

Anschliessend abspeichern des Files. 

Nun muss das DIH File in die Solr Pods hochgeladen werden
```
Change Directory in den Ordner searchservice/solr/configsets 
oc project solr-cloud-test
oc rsync gdi solr-0:/opt/solr/server/home
oc rsync gdi solr-1:/opt/solr/server/home
```

In einen Solr Pod einloggen. Es spielt keine Rolle in welchen.

```
oc rsh solr-0 /bin/bash
```

Configset gdi updaten

```
/opt/solr/server/scripts/cloud-scripts/zkcli.sh -z zookeeper.solr-cloud-test.svc:2181 -cmd upconfig -confdir /opt/solr/server/home/gdi/conf -confname gdi
```

Aus Solr Pod ausloggen und folgenden Curl Befehl ausführen

```
curl "http://solr-headless-solr-cloud-test.dev.so.ch/solr/admin/collections?action=MODIFYCOLLECTION&collection=gdi&collection.configName=gdi"
```
