#!/bin/bash

if [[ "$#" -eq 0 ]]
then
        curl -s 'https://warpdrive-lab.dev.symphony.com/jenkins/view/Security/job/security-pipeline-new/' | sed -n 's!.*pane desc indent-multiline">\(.*\)<br>.*https://\(.*\).gke.*!\1 \2!p' | sort
        exit 0
fi

if [[ "$#" -ne 2 ]]
then
	echo "Need (only) two arguments: the target application (km, sbe, hb, mg) and, either the epod namespace suffix number or the full epod namespace"
	exit 1
fi

if [[ (! "$2" =~ .*-.*) && -z "$EPNS" ]]
then
	echo "Need to set environment variable 'EPNS' to store the epod namespace prefix"
	exit 1
fi

NAMESPACE=""

if [[ "$2" =~ .*-.*  ]]
then
        NAMESPACE=$2
else
	NAMESPACE=$EPNS-$2
fi

CONTAINER_PATTERN=""
INIT=""

case $1 in
   "km") CONTAINER_PATTERN="keymanager-"
         INIT="source /opt/keymanager/conf/property_decryption_keys.rc && "
   ;;
   "sbe") CONTAINER_PATTERN="sbe-"
   ;;
   "hb") CONTAINER_PATTERN="hadoop-hbase-"
         INIT="echo \"alias hb='/opt/hbase/bin/hbase shell'\" >> ~/.bashrc && "
   ;;
   "mg") CONTAINER_PATTERN="mongo-"
         INIT="echo \"alias mg='/opt/mongo/bin/mongo localhost:27017/maestro --ssl --sslAllowInvalidCertificates'\" >> ~/.bashrc && "
   ;;
   *) echo "Unknown application $1: use km, sbe, or hb"
      exit 1
   ;;
esac

CONTAINER=`kubectl get pods -n $NAMESPACE | grep $CONTAINER_PATTERN | tr -s ' ' | cut -d ' ' -f1`

if [[ -z $CONTAINER ]]
then
	echo "Could not find a $1 container in namespace $NAMESPACE"
	exit 1
else
	echo "Found $1 container: $CONTAINER"
fi

kubectl -n $NAMESPACE exec -it $CONTAINER -- bash -c "$INIT bash"

