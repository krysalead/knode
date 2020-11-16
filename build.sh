#!/bin/sh
NODE_VERSION=14.10-alpine
USERNAME=krysalead

# docker login --username=${USERNAME}

for IMAGE_TYPE in dev prd 
do
    IMAGE_NAME="knode-${IMAGE_TYPE}:${NODE_VERSION}"
    DOCKERFILE="Dockerfile-${IMAGE_TYPE}"
    echo "Validation $DOCKERFILE"
    docker run --rm -i -v $PWD/.hadolint.yaml:/root/.config/hadolint.yaml hadolint/hadolint < $DOCKERFILE
    echo "Building $IMAGE_NAME"
    # OUTPUT=$(docker build -t ${IMAGE_NAME} -f $DOCKERFILE . | grep "Successfully built")
    # stringarray=($OUTPUT)
    # echo ${stringarray[${#stringarray[@]} - 1]]}
    # docker tag ${stringarray[${#stringarray[@]} - 1]]} ${USERNAME}/${IMAGE_NAME}
    # docker push ${USERNAME}/${IMAGE_NAME}
done
