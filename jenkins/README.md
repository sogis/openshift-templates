# Jenkins

## Install in an Openshift Environment

We use the Openshift included jenkins-ephemeral template to install Jenkins.
There are a few changes necessary for example the use of a configMap to inject agi env variables in the jenkins pod.
Therfore the adjusted template is stored in this repository.
First install the jenkins-env-configmap with oc apply. The configMap is stored in H:\BJSVW\Agi\GDI\Betrieb\Openshift\Pipelines.
The configMap includes env variables used in more then one pipeline.
Then we need a persistent volume claim named jenkins.
Finally install jenkins with
```
oc process -f jenkins.yaml  \
  | oc apply -f-
```

### Export/Import Jobs from one jenkins to another one
To export a job from one jenkins (eg test jenkins) to another one (eg prod jenkins) use jenkins-cli.jar and the export_import_jobs.sh script.
For exporting all jobs of an jenkins instance and importing it in another jenkins instance use
```
for i in $(java -jar ~/Downloads/jenkins-cli.jar -s https://jenkins-agi-apps-test.dev.so.ch -noCertificateCheck -auth "your-jenkins-user-name":your-jenkins-token list-jobs);do ./export_import_jobs.sh test integration $i; done
``` 
