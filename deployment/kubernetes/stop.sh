#!/bin/bash -e

DIR=$(dirname $(readlink -f "$0"))
EXT=*.yaml

# Set Bash color
ECHO_PREFIX_INFO="\033[1;32;40mINFO...\033[0;0m"
ECHO_PREFIX_ERROR="\033[1;31;40mError...\033[0;0m"

# Try command  for test command result.
function try_command {
    "$@"
    status=$?
    if [ $status -ne 0 ]; then
        echo -e $ECHO_PREFIX_ERROR "ERROR with \"$@\", Return status $status."
        exit $status
    fi
    return $status
}

# This script must be run as root
if [[ $EUID -ne 0 ]]; then
    echo -e $ECHO_PREFIX_ERROR "This script must be run as root!" 1>&2
    exit 1
fi

try_command hash kubectl > /dev/null

for i in $(find "$DIR" -maxdepth 1 -name "*service.yaml"); do
    len=$(echo $DIR | wc -m)
    i1=$(echo ${i:${len}} | sed 's/-service.yaml//')
    for j in $(kubectl get svc | awk '{print $1}' | sed -n '2, $p' | grep -v 'kubernetes'); do
        if [ "$i1" == "$j" ]; then
            kubectl delete -f "$i"
        fi
    done
done

for i in $(find "$DIR" -maxdepth 1 -name "*deployment.yaml"); do
    len=$(echo $DIR | wc -m)
    i1=$(echo ${i:${len}} | sed 's/-deployment.yaml//')
    for j in $(kubectl get pod | awk '{print $1}' | sed -n '2, $p' | awk -F '-' '{$NF=""; $(NF-1)=""; gsub("  ", "");gsub(" ", "-"); print}'); do
        if [ ${i1} == ${j} ]; then
            kubectl delete -f "${i}"
        fi
    done
done

kubectl delete secret self-signed-certificate 2> /dev/null || echo -n ""

rm -rf $DIR/$EXT
