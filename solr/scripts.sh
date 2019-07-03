# config auf Zookeeper hochladen
# in einem solr-pod ausführen
./zkcli.sh -z zk.solr-cloud-test.svc:2181 -cmd upconfig -confdir ../../solr/configsets/_default/conf/ -confname gdi

# Collection erstellen mit 3 solr Pods
curl "http://solr-headless-solr-cloud-test.dev.so.ch/solr/admin/collections?action=CREATE&name=gdi&numShards=1&replicationFactor=3"

# Dokument mit id dummy hinzufügen
curl -X POST -H 'Content-Type: application/json' 'http://solr-headless-solr-cloud-test.dev.so.ch/solr/gdi/update/json/docs?commit=true' --data-binary '{ "id": "dummy" }'

# Request für liveness und readiness
http://solr-headless-solr-cloud-test.dev.so.ch/solr/gdi/select?q=id%3Adummy&rows=1
