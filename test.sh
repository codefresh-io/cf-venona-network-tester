#!/bin/bash

timeout=60 # spend no more than 10s per request
testResult=0 # store final test result here
export IFS=","

set -o pipefail

function logDebug() {
    if [[ "$DEBUG" -eq "1" ]]; then
        echo $1
    fi
}

function log() {
    echo $1
}

function testUrl() {
    if [[ "$INSECURE" -eq "1" ]]; then
        curl --max-time $timeout -ksSf $1 > /dev/null 2>err.log
    else
        curl --max-time $timeout -sSf $1 > /dev/null 2>err.log
    fi

    return $?
}

function testUrls() {
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
}

function testKubernetes() {
    token=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
    hostAddr=""
    if [[ ! -z "$KUBERNETES_HOST" ]]; then
        hostAddr="$KUBERNETES_HOST"
    else
        hostAddr="https://$KUBERNETES_SERVICE_HOST:$KUBERNETES_PORT_443_TCP_PORT"
    fi
    logDebug "testing connectivity to kubernetes apiserver at: $hostAddr "
    curl -sfSk -H "Authorization: Bearer $token" $hostAddr --max-time $timeout > /dev/null 2>err.log

    exitStatus=$?

    if [[ "$DEBUG" -eq "1" ]]; then
        cat err.log # print error to logs
    fi

    if [[ "$exitStatus" -ne "0" ]]; then
        if [[ "$exitStatus" -eq "22" ]]; then
            # exit code 22 means we got 403 Forbidden response, which is good enough.
            logDebug "success: kubernetes apiserver"
        fi
        if [[ "$IN_CLUSTER" -eq "1" ]]; then
            cat err.log >> /dev/termination-log # write termination message
        fi
        log "can't reach kubernetes apiserver at: $hostAddr. try to specify a different apiserver address."
        testResult=1
    else
        logDebug "success: kubernetes apiserver"
    fi
}

testUrls
testKubernetes

if [[ $testResult -eq 1 ]]; then
    log "network test failed!"
    exit 1
else
    log "network test finished successfully!"
    exit 0
fi

