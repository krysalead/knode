# KNode

This is an image optimized for the Krysalead projects. It has the best practices in terms of Node for Docker. It can be used as well in other project but I put also my way of doing node in docker.
Feel free to comment or fork if you need.

The base image avoid to recompile the entire image preparation, the images in **example** folder gives the rest of the operation to produce DEV images and PROD images. It includes a build script to build and check your images.

The starter script allows to start various processes in the docker image according to the TASK_NAME env variable.

```
    dev) nodemon index.js --watch dist;;
    debug) nodemon --watch dist --debug --debug-brk=5858 index.js;;
    *) node index.js;;
```

## dev

```
FROM dknode-dev:14.10-alpine
# Copy the package.json isolated to avoid recompilation on source change
COPY "package.json" "package-lock.json" ./
RUN npm install --quiet
# Copy the full content of your source
COPY . .
# This is only if you require it (Typescript or packaging)
RUN npm run build
# This will start wait (to wait for another server) and then start the process according to the env variable TASK_NAME
CMD /wait && ./start.sh
```

Running the image with a runtime compiled source that will reload each time the compiled source change

```
docker run -ti -v ${PWD}/dist/:/app/dist/ -e TASK_NAME=dev MY_IMAGE_NAME
```

## production

will run in a production environement

```
FROM dknode:14.10-alpine AS build
COPY --chown=node:node "package.json" "package-lock.json" ./
# download only the dependencies from package-lock
RUN npm ci --quiet && npm cache clean --force
# copy the source code
COPY --chown=node:node . .
# build the code in ./dist
RUN npm run build

FROM build as prod
# Do not run as root
USER node
# get the previous stage compilation
COPY --from=build /dist /dist
CMD /wait && ./start.sh
```

# Build

You need a username and password on DockerHub

```
./build.sh DOCKER_HUB_USERNAME DOCKER_HUB_PASS
```
