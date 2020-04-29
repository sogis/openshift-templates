#!/bin/bash
if [ $# -lt 3 ]; then

  echo "Fehler: Not enough arguments"

  echo "Benutzung: $0 jenkinsfrom jenkinsto jobname (z.B. test integration data-service)"
  exit 1
fi
java -jar jenkins-cli.jar -s https://jenkins-agi-apps-$1.dev.so.ch -noCertificateCheck -auth "pfeiffer michael-admin-edit-view":118590e0b3983c6937e574bf3769808457 get-job $3 > /tmp/$3.xml
java -jar jenkins-cli.jar -s https://jenkins-agi-apps-$2.dev.so.ch -noCertificateCheck -auth "pfeiffer michael-admin-edit-view":11f2a28de30f5b159b576ed2f092b19ea5 create-job $3 < /tmp/$3.xml
