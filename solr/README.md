[Zookeeper](https://github.com/sogis/openshift-templates/tree/master/solr#zookeeper-because-coordinating-distributed-systems-is-a-zoo)

[Solr Cloud](https://github.com/sogis/openshift-templates/tree/master/solr#solr-cloud)

[Betrieb Solr Cloud im AGI](https://github.com/sogis/openshift-templates/tree/master/solr#betrieb-solr-cloud-im-agi)


# Zookeeper (Because coordinating distributed systems is a zoo)

### What is zookeeper
Here an selection of definitions

https://stackoverflow.com/questions/19043881/roles-of-zookeeper-in-solr-cloud
Zookeepers are a central repository for SolrCloud configuration. You can consider it as a distributed filesystem which can be accessed by all Solr nodes in the cluster. 
So if you change any config file you just need to inform or upload it to Zookeeper and not on every node in the cluster.

One more important responsibility of Zookeeper is to keep an eye on the state of all Solr nodes in the cluster. If any node goes down and a search request comes in for 
that node, Zookeeper routes it to an alternative replica node.

https://stackoverflow.com/questions/46332853/what-is-the-interaction-between-solr-and-zookeeper
A Single node Solr instance uses it's own configuration files usually in a conf folder containing files like schema.xml, stopwords.txt etc. 
But in Solr cloud context a collection is a logical index having group of cores. These group of cores need centralised configurations 
(same configuration shared among cores belonging to same collection). 
ZooKeeper is a centralised service for maintaining configuration information in a distributed system.
You can upload, download, and edit configuration files, so that all cores belonging to the same collection get same config set.

https://lucene.apache.org/solr/guide/6_6/solrcloud.html
ZooKeeper is mostly a black-box technology that you don’t need to worry about too much other than the initial configuration.(Solr in Action S.415f).
Zookeeper manages cluster state (as in solr Web GUI http://solr-headless-solr-cloud-production.apps.ocp.so.ch/solr/#/~cloud?view=graph) and distributes configuration files to nodes joining the cluster.
It's a kind of centralized configuration store. Centralized configuration allows all nodes in the cluster to download their configurations from a central location instead of a system
administrator having to push configuration changes to multiple nodes.

Solr uses Zookeeper for:
* Centralized configuration storage and distribution
* Detection and notification when the cluster state changes
* Shard-leader election

ZooKeeper organizes data into a hierarchical namespace similar to a filesystem. Each level in the hierarchy is called a znode. Each znode encapsulates basic metadata such as
creation time and last-modified time and can also store a small amount of data. ZooKeeper keeps znodes in memory for performance reasons.
You can have a look on the znodes in Solr WebGUI unter Cloud/Tree. 

A central concept in ZooKeeper is the ephemeral znode, which requires an active client connection to keep the znode alive.
If the client application that created the ephemeral znode goes away, the ephemeral znode is automatically deleted by ZooKeeper. 
When a Solr node joins the cluster, it creates an ephemeral znode under the /live_nodes node. Solr keeps an active connection to this node using the ZooKeeper API. 
If Solr crashes, the connection to the ephemeral znode is lost, causing that node to be considered gone. When the state of a znode changes, ZooKeeper notifies the other nodes in the cluster that one of the nodes is down. 
This is important so that Solr doesn’t try to send distributed query requests to the failed node.

### ZNODE WATCHER
Another core concept in ZooKeeper is that of a znode watcher. Any client application can register itself as a watcher of a znode. 
If the state of the znode changes, ZooKeeper will notify all registered watchers of the change. 
For instance, Solr registers as a watcher of the /clusterstate.json znode so that it can receive notifications when the state of the cluster changes, as when there is a new replica or a node is offline.

# Solr Cloud
Solr cloud supports
* Central configuration for the entire cluster
* Automatic load balancing and fail-over for queries
* ZooKeeper integration for cluster coordination and configuration

SolrCloud is flexible distributed search and indexing, without a master node to allocate nodes, shards and replicas. Instead, Solr uses ZooKeeper to manage these locations, depending on configuration files and schemas. 
Queries and updates can be sent to any server. Solr will use the information in the ZooKeeper database to figure out which servers need to handle the request.
If ZooKeeper goes offline, Solr can still respond to queries but will refuse to accept updates. Solr can respond to queries because each node caches the cluster state received from Zookeeper.

### Motivation behind Solr Cloud
* Scalability (Sharding and replication)
* High availability (replication)
* Consistency (Same Indexes on each replica every time)
* Simplicity (Scalability, High availability, and Consistency were already there before solr cloud but very complex)
* Elasticity (Add more replicas or split shards easily)

### Logical concept
A cluster can host multiple collections of Solr documents.
A collection can be partitioned into multiple shards. A shard is a subset of documents in the collection => Brauchts bei uns laut Daniel Wrigley nicht, da wir keine so grosse
collection haben.

### Physical concept
A cluster is made up of one or more Solr Nodes. Each of these Nodes can host multiple cores.
Each core in a cluster is a physical replica for a logical shard. Every core uses the same configuration specified for the collection that it is a part of.
The number of replicas that each shard has determines:
* The level of redundancy built into the collection.
* The theoretical limit in the number concurrent search requests that can be processed under heavy load

In solr cloud there are no masters or slaves. Instead every shard consists of at least one physical replica, exactly one of which is a leader.
Leaders are automatically elected, initially on first-come-first-served basis, and then based on the zookeeper process.

When a document is sent to a solr node for indexing the system first determines which Shard that belongs to and then which node is currently hosting the leader of
that shard. The document is then forwarded to the current leader for indexing and the leader forwards the update to all of the other replicas.

## Definitions
### core
A core is a uniquely named, managed, and configured index running in a Solr server. A Solr server can host one or more cores.
A core is composed of a set of configuration files, Lucene index files, and Solr’s transaction log.

### collection
A collection extends the concept of a uniquely named, managed, and configured index to one that is split into shards and distributed across multiple servers. 
The reason SolrCloud needs a new term (instead of core) is because each shard of a distributed index is hosted in a Solr core

## Ablageort der Indexe
Die Indexe liegen in home/collectionname_shardn_replica_n Verzeichnis. n ist jeweils mit der entsprechenden Ziffer des Shards oder der Replica zu ersetzen.

## Tools

### ZooKeeper Command Line Interface (CLI) script
/opt/solr/server/scripts/cloud-scripts/zkcli.sh is specific to solr => it includes command line arguments to deal with solr data in zookeeper and allows you to interact directly with Solr configuration
files stored in ZooKeeper.

#### upconfig
Lädt ein config Verzeichnis in zookeeper hoch. Der verteilt es dann auf die solr nodes. Im solr Pod müssen die Dateien nicht vorhanden sein.
Theoretisch könnte man zkcli.sh Skript auch von lokal ausführen. Dann brauchts aber ne Route für Zookeeper oder der Port 2181 muss von lokal nach Openshift offen sein.

#### downconfig
Mit downconfig kann man den aktuellen Stand eines config Verzeichnisses aus Zookeeper herunterladen.

### Collections API
https://lucene.apache.org/solr/guide/6_6/collections-api.html
The Collections API is used to enable you to create, remove, or reload collections, but in the context of SolrCloud you can also use it to create collections with a specific number of shards and replicas.


# Betrieb Solr Cloud im AGI

## Erstinstallation in Openshift

Zuerst müssen die notwendigen DB Credentials erstellt werden.
Lokal eine Datei user.txt erstellen mit dem Usernamen sogis_service.
Ausserdem eine Datei password.txt mit dem Passwort des Users erstellen (im keepass)
Achtung die Dateien müssen genau so heissen.
Dann das Secret erstellen
```
oc create secret generic dbcredentials --from-file user.txt --from-file password.txt
```
Die weiteren Komponenten werden mit den folgenden Schritten erstellt.
```
oc create -f 1_poddisruptionbudget.yaml
oc process -f 2_zk.yaml | oc apply -f-
oc process -p ENV="test" -p SOLR_JAVA_MEM="-Xms1024m -Xmx1024m" -p MEMORY_LIMIT="2048M" -p CPU_LIMIT="1600m" -p MEMORY_REQUEST="1024M" -p CPU_REQUEST="100m" -p LOGGING_LEVEL="WARN" -p DBSERVER='geoweb-t.rootso.org' -f 3_statefulset_solr.yaml | oc apply -f-
oc create -f 4_poddisruptionbudget_solr.yaml
oc process -p ENV="test" -f 5_service-headless-solr.yaml | oc apply -f-
oc process -p ENV="test" -f 6_exporter-deployment.yaml | oc apply -f-
```
Je nach Umgebung muss darauf geachtet werden die Ressource Limits korrekt zu setzen. In der Testumgebung braucht es gar keine (nachträglich aus dem Statefulset entfernen), auf der Integration sollten die Requested Resources tiefer sein als die Limits auf der Produktion identisch. Solr Exporter sammelt Metriken und andere Daten von Solr, die über Prometheus ausgewertet werden können. Wenn man den Output der Metriken direkt anschauen möchte kann man noch ein Route zum solr-exporter service legen.
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
### Collection erstellen mit 2 solr Pods (solr-headless-solr-cloud-integration.apps.ocp.so.ch ist zu ersetzen mit der Url der Solr Cloud)
```
curl "http://solr-headless-solr-cloud-test.apps.ocp.so.ch/solr/admin/collections?action=CREATE&name=gdi&numShards=1&replicationFactor=2"
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
curl -X POST -H 'Content-Type: application/json' 'http://solr-headless-solr-cloud-test.apps.ocp.so.ch/solr/gdi/update/json/docs?commit=true' --data-binary '{ "id": "dummy" }'
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
Mit der gesetzten *updateStrategy* *RollingUpdate* werden die Pods in umgekehrter Reihenfolge automatisch gestartet.

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

Anschliessend ins solr Repo wechseln und die Dateien *dih_geodata_config.xml.orig* und *dih_metadata_config.xml.orig* nach *dih_geodata_config.xml* und *dih_metadata_config.xml* kopieren und 
an die entsprechende Umgebung anpassen (DB Connection und DB User und Passwort setzen).

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
curl "http://solr-headless-solr-cloud-test.apps.ocp.so.ch/solr/admin/collections?action=MODIFYCOLLECTION&collection=gdi&collection.configName=gdi"
```

## Unterhalt
### Anpassung Statefulset

Nach der Anpassung eines Statefulsets innerhalb von *spec.template* sollten die Pods aufgrund der in *updateStrategy* gesetzten *RollingUpdate* Strategie in umgekehrter Reihenfolge automatisch neu gestartet werden.
Sollte dies nicht geschehen die Pods in umgekehrter Reihenfolge löschen. Bitte immer nur ein Pod nach dem anderen löschen und warten bis dieser wieder *ready* ist.
Dies ist bisher nur für das Solr Statefulset umgesetzt.
Falls es bei Solr zu Problemen mit dem Starten der Pods kommen mit *oc patch* die ReadinessProbe entfernen. Sollte dies nicht ausreichen die *updateStrategy* mit
```
oc patch statefulset solr -p '{"spec":{"updateStrategy":{"type":"OnDelete"}}}'
```
auf *OnDelete* setzen und anschliessend die Pods von Hand löschen.

### Update configSet

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
curl "http://solr-headless-solr-cloud-test.apps.ocp.so.ch/solr/admin/collections?action=RELOAD&name=gdi"
```

## Disaster Recovery
Wenn aus irgendeinem Grund beide solr Pods gleichzeitig vorübergehend gelöscht wurden (mussten) oder in keinen State ready mehr kommen, dann können diese wegen der Readiness Probe nicht mehr starten.
Diese schlägt dann beim solr-0 Pod fehl. solr-1 startet dann gar nicht erst. 

**alte Methode mit *updateStrategy OnDelete*-**

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

**Neue Methode mit der eingestellten *updateStrategy RollingUpdate*-**

In diesem Fall muss die Readiness Probe folgendermassen entfernt werden
```
oc patch statefulset/solr --type json -p '[{ "op": "remove", "path": "/spec/template/spec/containers/0/readinessProbe" }]'
```
Anschliessend sollte der solr-0 Pod automatisch und erfolgreich neu starten und anschliessend auch der solr-1 Pod.
Wenn beide Pods wieder oben sind kann die Readiness Probe wieder hinzugefügt werden.
```
oc patch statefulset/solr -p '{"spec":{"template":{"spec":{"containers":[{"name":"solr","readinessProbe":{"httpGet":{"path":"/solr/admin/info/system","port":8983}}}]}}}}'

```
Anschliessend starten die Pods in umgekehrter Reihenfolge neu. Sollte dies nicht funktionieren mit
```
oc patch statefulset solr -p '{"spec":{"updateStrategy":{"type":"OnDelete"}}}'
```
zur alten Methode wechseln.

**Anmerkung**

Die hier beschriebenen Probleme sollten zukünftig nicht mehr auftreten, da die frühere Anpassung der Readiness Probe auf den path */solr/gdi/select?q=id%3Adummy&rows=1* 
nicht mehr verwendet wird,sondern es bleibt bei der im Lucid Helm Chart vorhandenen Readiness Probe. 
Die Ursache für das nicht mehr starten der Pods nach einem Neustart des Openshift Clusters liegt vermutlich in dieser fehlerhaften Readiness Probe. Die Readiness Probe
aus dem Lucid Helm Chart scheint dagegen zu funktionieren, zumindest tut sie dies wenn man beide Pods gleichzeitig löscht. Eine Verifikation dieser Hypothese steht noch aus,
da ein Cluster Shutdown nicht simuliert werden kann.

Bei Zookeeper sollte es keine Probleme geben, wenn mehr als ein Pod zeitgleich weg ist. Zwar kann dann vorübergehend kein Leader mehr gewählt werden, die fehlenden Pods sollten aber schnell
wieder gestartet werden und das System heilt sich dann selbst. Probleme kann es lediglich geben, wenn mehr als ein Pod dauerhaft nicht mehr hoch kommt.

#### .snapshot Ordner im pvc

Solr kann nicht starten, wenn sich im gemounteten PVC ein .snapshot Ordner befindet.
Deshalb wurde auf dem gemounteten PVCs solr-claim-solr-0 und solr-claim-solr-1 die Snapshot Ordner entfernt. Snapshots werden hier folgerichtig nicht gemacht.

Diese Massnahmen wurden am 30.7.2019 mit dem AIO (Robert Ming) besprochen und beim Umbau des Network Attached Storage am 28.6. nochmals, da nach der Umstellung wieder ein .snapshot Ordner vorhanden war.

## Hilfreiche Befehle

Skalieren eines Statefulsets
```
oc scale sts name --replicas=2
```
