#!/bin/sh
COMMAND=${TASK_NAME:-start}
echo "Running command $COMMAND"
echo "This image is not aimed to be production ready, use the production image associated"
case $COMMAND in
    start)  node index.js;;
    dev) nodemon index.js --watch dist;;
    debug) nodemon --watch dist --debug --debug-brk=5858 index.js
esac