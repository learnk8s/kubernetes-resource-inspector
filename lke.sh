#!/bin/bash
node=$(kubectl get node -o name | head -n 1)
file="/host/var/lib/kubelet/config.yaml"
input="./.lke.yaml"
kubectl debug "$node" -it  --image xxradar/hackon -- cat $file | tail -n +2 > $input;

echo 'system reserved:'
echo "cpu="$(cat $input | yq -r '.systemReserved.cpu // 0');
echo "memory="$(cat $input | yq -r '.systemReserved.memory // 0');
echo $'\n';

echo 'kubelet reserved:';
echo "cpu="$(cat $input | yq -r '.kubeReserved.cpu // 0');
echo "memory="$(cat $input | yq -r '.kubeReserved.memory // 0');
echo $'\n';

echo 'eviction threshold:';
echo "memory="$(cat $input | yq -r '.evictionHard."memory.available" // 0');

rm $input;