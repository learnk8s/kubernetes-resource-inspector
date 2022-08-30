#!/bin/bash
node=$(kubectl get node -o name | head -n 1)
file="/host/etc/kubernetes/kubelet/kubelet-config.json"
input="./.eks.json"
kubectl debug "$node" -it  --image xxradar/hackon -- cat $file | tail -n +2 > $input;

echo 'system reserved:'
echo "cpu="$(cat $input | jq -r '.systemReserved.cpu // 0');
echo "memory="$(cat $input | jq -r '.systemReserved.memory // 0');
echo $'\n';

echo 'kubelet reserved:';
echo "cpu="$(cat $input | jq -r '.kubeReserved.cpu // 0');
echo "memory="$(cat $input | jq -r '.kubeReserved.memory // 0');
echo $'\n';

echo 'eviction threshold:';
echo "memory="$(cat $input | jq -r '.evictionHard."memory.available" // 0');

rm $input;