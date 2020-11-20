# KNode

This is an image optimized for the Krysalead projects. It has the best practices in terms of Node for Docker.

The base image avoid to recompile the entire image preparation, the images in example folder gives the rest of the operation to produce DEV images and PROD images.

## dev.sh

This scripts allow to start various processed in the docker image according to the TAST_NAME env variable.

**production** will start the image with

```
node index.js
```

**dev** will start the image with

```
nodemon index.js --watch dist
```

**debug** will start the image with

```
nodemon --watch dist --debug --debug-brk=5858 index.js
```

## run.sh

will run only the production command

# Build

```
./build.sh DOCKER_HUB_PASS
```
