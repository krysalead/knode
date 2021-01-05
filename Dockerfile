ARG NODE_BASE_VERSION=14.10-alpine
FROM node:$NODE_BASE_VERSION
ARG ENV 
ARG PORTS
LABEL maintainer="krysalead@gmail.com"
EXPOSE $PORTS
# install git, python and compiler for native dependency code
RUN apk add git=2.24.3-r0 g++=9.3.0-r0 make=4.2.1-r2 python3=3.8.2-r1 --no-cache
RUN ln -sf python3 /usr/bin/python
RUN rm -R /var/cache/apk/
# Creating a working folder and giving the owner rights to node user
RUN mkdir /app && chown -R node:node /app
WORKDIR /app
# For dev we add nodemon,typescript compiler, run first as the below ADD are redownloaded each build
RUN if [ "$ENV" = "dev" ] ; then npm install -g nodemon@2.0.6 typescript@4.0.5; fi
# install wait to allow starting after another process is available
ADD https://github.com/ufoscout/docker-compose-wait/releases/download/2.2.1/wait /wait
RUN chmod +x /wait
# start script allow flexibility in runtime command, it will ensure node as runner and not NPM
COPY run.sh .
RUN mv run.sh start.sh
RUN chmod +x start.sh