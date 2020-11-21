#!/bin/bash
NODE_VERSION=14.10-alpine
USERNAME=$1
PASSWORD=$2

CHANGES=$(git diff-tree --no-commit-id --name-only -r $3)
echo "CHANGES: $CHANGES"
DO_BUILD=0
IMAGE_LIST=""
for file in $CHANGES 
do
    if [[ "$file" =~ ^(build\.sh|Dockerfile)$ ]]; then
        DO_BUILD=1
        IMAGE_LIST="dev prd"
    else
        if [[ "$file" =~ ^(dev\.sh)$ ]]; then
            DO_BUILD=1
            IMAGE_LIST="dev $IMAGE_LIST"
        fi
        if [[ "$file" =~ ^(run\.sh)$ ]]; then
            DO_BUILD=1
            IMAGE_LIST="prd $IMAGE_LIST"
        fi
    fi
done

if [ $DO_BUILD == 0 ]; 
then
    echo "Nothing to build"
    exit 0
fi

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
    if [ $? != 0 ];
    then
        echo "Failed to build the image, see error above"
        exit 3
    fi
    stringarray=($OUTPUT)
    $TAG=${stringarray[${#stringarray[@]} - 1]}
    echo "Tagging $IMAGE_NAME ($TAG)"
    # tag the image with the hash
    docker tag $TAG ${USERNAME}/${IMAGE_NAME}
    if [ ! -z "$PASSWORD" ];
    then
        echo "Pushing $IMAGE_NAME"
        docker push ${USERNAME}/${IMAGE_NAME}
    fi
done