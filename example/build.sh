#!/bin/bash
USERNAME=krysalead
IMAGE_NAME=example
if [ $IMAGE_TYPE == dev ];
then
    DOCKERFILE="Dockerfile.dev"
else
    DOCKERFILE="Dockerfile.prod"
fi
echo "Validation '$DOCKERFILE'"
# Lint the image
docker run --rm -i -v $PWD/.hadolint.yaml:/root/.config/hadolint.yaml hadolint/hadolint < $DOCKERFILE
if [ $? != 0 ];
then
    echo "Failed to lint the image, see error above"
    exit 2
fi
# Authentication to the docker hub, it will interactively request your password
docker login -u ${USERNAME} -p $1
if [ $? != 0 ];
then
    echo "Failed to login to the docker hub, see error above"
    exit 1
fi
echo "Building $IMAGE_NAME"
# Get the hash of the image
OUTPUT=$(docker build -t ${IMAGE_NAME} . | grep "Successfully built")
if [ $? != 0 ];
then
    echo "Failed to build the image, see error above"
    exit 3
fi
stringarray=($OUTPUT)
echo "Tagging $IMAGE_NAME"
# tag the image with the hash
TAG=${stringarray[${#stringarray[@]} - 1]}
docker tag $TAG ${USERNAME}/${IMAGE_NAME}-${TAG}
echo "Pushing $IMAGE_NAME-${TAG}"
docker push ${USERNAME}/${IMAGE_NAME}-${TAG}