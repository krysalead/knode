#!/bin/bash
NODE_VERSION=14.10-alpine
USERNAME=krysalead

DOCKERFILE="Dockerfile"
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
for IMAGE_TYPE in dev prd 
do
    if [ $IMAGE_TYPE == dev ];
    then
        ports='4000 5858'
        suffix="-dev"
    else
        ports[prd]="4000"
        suffix[prd]=""
    fi
    IMAGE_NAME="dknode${suffix}:${NODE_VERSION}"
    echo "Building $IMAGE_NAME"
    # Get the hash of the image
    OUTPUT=$(docker build -t ${IMAGE_NAME} --build-arg ENV=${IMAGE_TYPE} --build-arg PORTS="$ports" . | grep "Successfully built")
    if [ $? != 0 ];
    then
        echo "Failed to build the image, see error above"
        exit 3
    fi
    stringarray=($OUTPUT)
    echo "Tagging $IMAGE_NAME"
    # tag the image with the hash
    docker tag ${stringarray[${#stringarray[@]} - 1]} ${USERNAME}/${IMAGE_NAME}
    echo "Pushing $IMAGE_NAME"
    docker push ${USERNAME}/${IMAGE_NAME}
done