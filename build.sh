#!/bin/bash
NODE_VERSION=14.10-alpine
USERNAME=$1
PASSWORD=$2
IMAGE_LIST="dev prd"

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
if [ ! -z "$PASSWORD" ];
then
    echo "Connecting to docker hub"
    docker login -u ${USERNAME} -p $PASSWORD
fi

if [ $? != 0 ];
then
    echo "Failed to login to the docker hub, see error above"
    exit 1
fi
for IMAGE_TYPE in $IMAGE_LIST 
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
    echo "docker build -t ${IMAGE_NAME} --build-arg ENV=${IMAGE_TYPE} --build-arg PORTS="$ports" --build-arg NODE_BASE_VERSION=${NODE_VERSION} ."
    OUTPUT=$(docker build -t ${IMAGE_NAME} --build-arg ENV=${IMAGE_TYPE} --build-arg PORTS="$ports" --build-arg NODE_BASE_VERSION=${NODE_VERSION} . | tee /dev/stderr | grep "Successfully built")
    STATUS=$?
    if [ $STATUS -eq 0 ];
    then
        echo "Failed to build the image, see error above ($STATUS)"
        exit 3
    fi
    if [ ! -z "$PASSWORD" ];
    then
        stringarray=($OUTPUT)
        TAG=${stringarray[${#stringarray[@]} - 1]}
        echo "Tagging $IMAGE_NAME ($TAG)"
        # tag the image with the hash
        docker tag $TAG ${USERNAME}/${IMAGE_NAME}
        echo "Pushing $IMAGE_NAME"
        docker push ${USERNAME}/${IMAGE_NAME}
    else
        echo "Build completed not uploaded to Docker hub"
    fi
done