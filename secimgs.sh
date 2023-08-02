#!/bin/bash
LIST=`gum spin --spinner line --title "Fetching docker images list..." --timeout 5s --show-output -- gcloud container images list --repository us.gcr.io/symphony-gce-dev/sym/security/base/dev | tail -n +2 | grep -v chsm | grep -v ssm`
IMAGE=`gum choose $LIST`
if [[ $? -eq 130 ]]
then
	exit 0
fi
docker run -it $IMAGE bash
