# Install or Update pgwatch2 in Openshift
Checkout Template repo

cd pgwatch

run
``` 
oc process -p env=test -p version=1.5.1 -f pgwatch.yaml  | oc apply -f-
```
