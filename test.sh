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
    if [[ ! -z "$KUBERNETES_HOST" ]]; then
        logDebug "testing connectivity to kubernetes apiserver at: $KUBERNETES_HOST"

        if [[ "$INSECURE" -eq "1" ]]; then
            echo "" | kubectl version --server $KUBERNETES_HOST --request-timeout=3s -v=8 --insecure-skip-tls-verify=true > /dev/null 2>err.log
        else
            echo "" | kubectl version --server $KUBERNETES_HOST --request-timeout=3s -v=8 > /dev/null 2>err.log
        fi
    else
        logDebug "testing connectivity to kubernetes apiserver"
        if [[ "$INSECURE" -eq "1" ]]; then
            echo "" | kubectl version --request-timeout=3s -v=8 --insecure-skip-tls-verify=true > /dev/null 2>err.log
        else
            echo "" | kubectl version --request-timeout=3s -v=8 > /dev/null 2>err.log
        fi
    fi

    exitStatus=$?

    if [[ "$DEBUG" -eq "1" ]]; then
        cat err.log # print error to logs
    fi

    if [[ "$exitStatus" -ne "0" ]]; then
        if [[ "$IN_CLUSTER" -eq "1" ]]; then
            cat err.log >> /dev/termination-log # write termination message
        fi
        if [[ ! -z "$KUBERNETES_HOST" ]]; then
            log "can't reach kubernetes apiserver at: $KUBERNETES_HOST. try to specify a different apiserver address."
        else
            log "can't reach kubernetes apiserver. try to specify a different apiserver address."
        fi
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

