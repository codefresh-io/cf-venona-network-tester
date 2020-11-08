#!/bin/bash

function logDebug() {
    if [[ "$DEBUG" -eq "1" ]]; then
        echo $1
    fi
}

function log() {
    echo $1
}

timeout=10 # spend no more than 10s per request
function testUrl() {
    if [[ "$INSECURE" -eq "1" ]]; then
        curl --max-time $timeout -ksSf $1 > /dev/null 2>err.log
    else
        curl --max-time $timeout -sSf $1 > /dev/null 2>err.log
    fi

    return $?
}

export IFS=","

testResult=0
for url in $URLS; do
  logDebug "testing: $url"
  testUrl $url
  testExitCode=$?
  if [[ "$DEBUG" -eq "1" ]]; then
    cat err.log # print error to logs
  fi
  if [[ "$testExitCode" -ne "0" ]]; then
    if [[ "$IN_CLUSTER" -eq "1" ]]; then
        cat err.log >> /dev/termination-log # write termination message
    fi
    log "can't reach: $url"
    testResult=1
  else
    logDebug "success: $url"
  fi
done

if [[ $testResult -eq 1 ]]; then
    log "network test failed!"
    exit 1
else
    log "network test finished successfully!"
    exit 0
fi

