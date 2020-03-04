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
oc process -f 2_zk.yaml -p RESOURCE_MEMORY_LIMIT="150M" -p RESOURCE_CPU_LIMIT="200m" -p RESOURCE_MEMORY_REQ="75M" -p RESOURCE_CPU_REQ="10m" | oc apply -f-
oc process -p ENV="test" -p SOLR_JAVA_MEM="-Xms1024m -Xmx1024m" -p MEMORY_LIMIT="2048M" -p CPU_LIMIT="1600m" -p MEMORY_REQUEST="1024M" -p CPU_REQUEST="100m" -p LOGGING_LEVEL="INFO" -p DBSERVER='geoweb-t.rootso.org' -f 3_statefulset_solr.yaml | oc apply -f-
oc create -f 4_poddisruptionbudget_solr.yaml
oc process -p ENV="test" -f 5_service-headless-solr.yaml | oc apply -f-
oc process -p ENV="test" -f 6_exporter-deployment.yaml | oc apply -f-
```
Je nach Umgebung muss darauf geachtet werden die Ressource Limits korrekt zu setzen. In der Testumgebung braucht es gar keine (nachträglich aus dem Statefulset entfernen), auf der Integration sollten die Requested Resources tiefer sein als die Limits auf der Produktion identisch. Solr Exporter sammelt Metriken und andere Daten von Solr, die über Prometheus ausgewertet werden können. Wenn man den Output der Metriken direkt anschauen möchte kann man noch ein Route zum solr-exporter service legen.
Nach Anpassung der Statefulsets müssen die Zookeeper Pods gelöscht werden. Die Solr Pods werden später ohenhin noch gelöscht.
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

### AGI configSet hochladen

Dies ist aus zweierlei Gründen notwendig. 
Zum einen ist in dem configSet auch die PostgreSql Java lib enthalten, die Solr für die Abfrage der DB bei der Indexberechnung benötigt.Diese muss in beiden Solr Pods am im gdi/conf/solrconfig.xml definierten Ort vorhanden sein.
Zum zweiten muss das configSet für das Hochladen in Zookeeper im Pod vorhanden sein. Dies funktioniert nur aus dem Pod, da der Port 2181 nur innerhalb Openshifts erreichbar ist. 
Für den Betrieb von Solr bräuchte es das configSet nicht physisch im Solr Pod. Das configSet wird durch Zookeeper verwaltet.

Zuerst in den Solr Pods das Verzeichnis gdi anlegen
```
oc rsh solr-0 /bin/bash
mkdir /opt/solr/server/home/gdi
exit
oc rsh solr-1 /bin/bash
mkdir /opt/solr/server/home/gdi
exit
```

Dann das configSet hochladen
```
git clone https://github.com/sogis/solr.git
cd solr
oc rsync conf solr-0:/opt/solr/server/home/gdi
oc rsync conf solr-1:/opt/solr/server/home/gdi
```

In einen beliebigen solr Pod (solr-0 oder solr-1) einloggen und configset gdi updaten.
Wie oben beschrieben geht dies nur aus Solr, da der Port 2181 ansonsten zu ist.
```
oc rsh solr-0 /bin/bash
/opt/solr/server/scripts/cloud-scripts/zkcli.sh -z zookeeper.solr-cloud-test.svc:2181 -cmd upconfig -confdir /opt/solr/server/home/gdi/conf -confname gdi
```
### configName der collection zu gdi korrigieren
Notwendig, da beim Create Befehl für die Collection weiter oben gdi.AUTOCREATED als configName verwendet wird.
```
curl "http://solr-headless-solr-cloud-test.dev.so.ch/solr/admin/collections?action=MODIFYCOLLECTION&collection=gdi&collection.configName=gdi"
```

## Update configSet

Unter https://github.com/sogis/solr befinden sich das für die Suche notwendige configSet inklusive der Dataimporthandler (DIH Files) dih_geodata_config.xml und dih_metadata_config.xml. dih_metadata ist für die Suche nach Kartenlayern und in deren Metadaten. dih_geodata für alle weiteren Objektsuchen. 
Für ein Update des configSets wird folgendermassen vorgegangen.
Beispiel: Hinzufügen einer neuen  bzw Löschen oder Anpassen einer bestehenden Suche (Beispiel für die Testumgebung):

```
git clone https://github.com/sogis/solr.git
cd solr/config
```

Kopieren der entsprechenden DIH orig Files und anpassen der DB Verbindung
Hinzufügen bzw. Löschen oder Anpassen der entity im entsprechenden DIH File. Beispiel 
```
<entity name="ch_so_afu_abbaustellen_abbaustellen" query="SELECT * FROM afu_abbaustellen_pub.abbaustelle_solr_v">
</entity>
```

Anzupassen sind hier im Tag *\<entity\>* *name* und *query*. *name* ist der Facet Name aus dem Eintrag im AGDI unter Dataset/Solr Facet, wobei die Punkte durch Unterstriche ersetzt werden müssen. Query frägt den für die Suche erstellten View ab.

Anschliessend abspeichern des Files. 

Nun muss das DIH File in einen Solr Pod hochgeladen werden. Auch hier gilt wieder: Dies ist nur erforderlich, da das Solr Skript für die Verwaltung des configSets in Zookeeper, wegen des geschlossenen Ports 2181, nur aus einem Pod in Openshift ausgeführt werden kann.
```
cd ..
oc project solr-cloud-test
oc rsync conf solr-0:/opt/solr/server/home/gdi
```

In den Solr Pod, in den das configSet hochgeladen wurde, einloggen.

```
oc rsh solr-0 /bin/bash
```

Configset gdi updaten.
Falls man nur ein einzelnes File angepasst hat genügt der folgende Befehl, der das angepasste File, dih_geodata_config.xml, in Zookeeper hochlädt.
```
/opt/solr/server/scripts/cloud-scripts/zkcli.sh -z zookeeper.solr-cloud-test.svc:2181 -cmd putfile /configs/gdi/dih_geodata_config.xml /opt/solr/server/home/gdi/conf/dih_geodata_config.xml
```
Wenn mehrere Dateien angepasst wurden kann mit dem folgenden Befehl das gesamte configSet upgedated werden.
```
/opt/solr/server/scripts/cloud-scripts/zkcli.sh -z zookeeper.solr-cloud-test.svc:2181 -cmd upconfig -confdir /opt/solr/server/home/gdi/conf -confname gdi
```

Aus Solr Pod ausloggen und folgenden Curl Befehl ausführen, um die Collection neu zu laden.

```
curl "http://solr-headless-solr-cloud-test.dev.so.ch/solr/admin/collections?action=RELOAD&name=gdi"
```

## Disaster Recovery
Wenn aus irgendeinem Grund beide solr Pods gleichzeitig vorübergehend gelöscht wurden (mussten) oder in keinen State ready mehr kommen, dann können diese wegen der Readiness Probe nicht mehr starten.
Diese schlägt dann beim solr-0 Pod fehl. solr-1 startet dann gar nicht erst.
In diesem Fall muss die Readiness Probe folgendermassen entfernt werden
```
oc patch statefulset/solr --type json -p '[{ "op": "remove", "path": "/spec/template/spec/containers/0/readinessProbe" }]'
```
Anschliessend den solr-0 Pod deleten. Dieser sollte danach wieder erfolgreich starten und anschliessend auch der solr-1 Pod.
Wenn beide Pods wieder oben sind kann die Readiness Probe wieder hinzugefügt werden.
```
oc patch statefulset/solr -p '{"spec":{"template":{"spec":{"containers":[{"name":"solr","readinessProbe":{"httpGet":{"path":"/solr/gdi/select?q=id%3Adummy&rows=1","port":8983}}}]}}}}'
```
Anschliessend zunächst einen der beiden solr Pods deleten (es ist egal welchen), warten bis dieser gestartet und ready ist und dann den anderen solr Pod deleten.

Bei Zookeeper sollte es keine Probleme geben, wenn mehr als ein Pod zeitgleich weg ist. Zwar kann dann vorübergehend kein Leader mehr gewählt werden, die fehlenden Pods sollten aber schnell
wieder gestartet werden und das System heilt sich dann selbst. Probleme kann es lediglich geben, wenn mehr als ein Pod dauerhaft nicht mehr hoch kommt.
