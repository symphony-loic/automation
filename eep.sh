#!/bin/bash

enter_epod() {

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

	CONTAINER=`gum spin --spinner monkey --title "Locating container..." --timeout 2s --show-output -- kubectl get pods -n $NAMESPACE | grep $CONTAINER_PATTERN | tr -s ' ' | cut -d ' ' -f1`

	if [[ -z $CONTAINER ]]
	then
		echo "Could not find a $1 container in namespace $NAMESPACE"
		exit 1
	fi

	kubectl -n $NAMESPACE exec -it $CONTAINER -- bash -c "$INIT bash"
}



if [[ "$#" -eq 0 ]]
then
	EPODS=$(gum spin --spinner minidot --title "Fetching active epods..." --timeout 4s --show-output -- curl -s 'https://warpdrive-lab.dev.symphony.com/jenkins/view/Security/job/security-pipeline-new/' | grep "class=\"build-stop\"" | sed -n 's!.*pane desc indent-multiline">\(.*\)<br>.*https://\(.*\).gke.*!\1:\2!p' | sort)
	if [[ -n $EPODS ]]
	then
		EPOD=`gum choose -- $EPODS`
		if [[ $? -eq 130 ]]
		then
			exit 0
		fi
		EPOD=`echo $EPOD | cut -d ':' -f2`
		APPLICATION=`gum choose -- km hb sbe mg`
		if [[ $? -eq 130 ]]
		then
			exit 0
		fi
		enter_epod $APPLICATION $EPOD
	else
		echo No active epods found
	fi
        exit 0
fi

if [[ "$#" -ne 2 ]]
then
	echo "Need (only) two arguments: the target application (km, sbe, hb, mg) and, either the epod namespace suffix number or the full epod namespace ; or no arguments at all"
	exit 1
fi

if [[ (! "$2" =~ .*-.*) && -z "$EPNS" ]]
then
	echo "Need to set environment variable 'EPNS' to store the epod namespace prefix"
	exit 1
fi

enter_epod $1 $2

