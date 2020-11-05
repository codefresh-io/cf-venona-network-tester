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
    if [[ "$DEBUG" -eq "1" ]]; then
        if [[ "$INSECURE" -eq "1" ]]; then
            curl --max-time $timeout -ksSf $1 > /dev/null
        else
            curl --max-time $timeout -sSf $1 > /dev/null
        fi
    else
        if [[ "$INSECURE" -eq "1" ]]; then
            curl --max-time $timeout -ksSf $1 > /dev/null 2>&1
        else
            curl --max-time $timeout -sSf $1 > /dev/null 2>&1
        fi
    fi

    return $?
}

export IFS=","

testResult=0
for url in $URLS; do
  logDebug "testing connection to: $url"
  testUrl $url
  testExitCode=$?
  if [[ "$testExitCode" -ne "0" ]]; then
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

