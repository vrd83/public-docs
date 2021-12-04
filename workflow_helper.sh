#!/bin/bash

# Constants
RELEASE_PATCH="release-patch"
RELEASE_MINOR="release-minor"
RELEASE_MAJOR="release-major"

# Fetch current version using gcloud sdk
CUR_VER=$(gcloud run services describe $GCP_CLOUD_RUN_SERVICE --format='flattened(metadata.annotations)' --region=$GCP_REGION | grep $GCP_CLOUD_RUN_SERVICE: | grep -o '.....$')

# Validate argument. I could remove this as calling the script with the Makefile enforces the correct argument but it's nice to have as reference. 
if [ ${1} != ${RELEASE_PATCH} ] && [ ${1} != ${RELEASE_MINOR} ] && [ ${1} != ${RELEASE_MAJOR} ];
then
  echo "Argument [ ${1} ] must be one of [ ${RELEASE_PATCH} | ${RELEASE_MINOR} | ${RELEASE_MAJOR} ]."
  exit 1
fi

# Print current version
echo
echo "Old: $CONTAINER_NAME:$CUR_VER"

# Increment tag
version_patch=$(echo $CUR_VER | grep -Eo "[0-9]+$")
version_minor=$(echo $CUR_VER | grep -Eo "[0-9]+\.[0-9]+$" | grep -Eo "^[0-9]+")
version_major=$(echo $CUR_VER | grep -Eo "^[0-9]+")

if [ ${1} = "${RELEASE_PATCH}" ];
then
  let "version_patch=version_patch+1"
elif [ ${1} = "${RELEASE_MINOR}" ];
then
  version_patch=0
  let "version_minor=version_minor+1"
elif [ ${1} = "${RELEASE_MAJOR}" ];
then
  version_patch=0
  version_minor=0
  let "version_major=version_major+1"
fi

# Store the new version as an environment variable
export NEW_VER="$version_major.$version_minor.$version_patch"

echo "New: $CONTAINER_NAME:$NEW_VER"
echo

# Docker tag and push
docker tag "$CONTAINER_NAME:latest" "$CONTAINER_NAME:$NEW_VER"
docker push "$CONTAINER_NAME:$NEW_VER"
echo

# Git tag and push
git tag -a "$NEW_VER" -m "$NEW_VER"
git push origin "$NEW_VER"

# Update Cloud Run service
gcloud run services update $GCP_CLOUD_RUN_SERVICE --project=$GCP_PROJECT --region=$GCP_REGION --image="$CONTAINER_NAME:$NEW_VER"