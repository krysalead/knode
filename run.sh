#!/bin/sh
TASK="${TASK:-start}"
MAIN="${MAIN:-src/main}"
COMMAND=${LANG}_${TASK}
echo "Running command $COMMAND"
echo "This image is not aimed to be production ready, use the production image associated"
# We can extend the list on demand
case $TASK in
    dev) nodemon --config nodemon.json ${MAIN};;
    debug) nodemon --config nodemon.json --debug --debug-brk=5858 ${MAIN};;
    *) node ${MAIN};;
esac