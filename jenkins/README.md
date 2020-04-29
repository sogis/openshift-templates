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
