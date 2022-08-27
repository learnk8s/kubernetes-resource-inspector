#!/bin/bash
node=$(kubectl get node -o name | head -n 1)
file="/host/etc/kubernetes/kubelet/kubelet-config.json"
input="./.eks.json"
kubectl debug "$node" -it  --image xxradar/hackon -- cat $file | tail -n +2 > $input;

echo 'os reserved'
echo 'cpu=100m';
echo 'memory=100Mi';
echo $'\n';

echo 'kubelet reserved:';
echo "cpu="$(cat $input | jq -r '.kubeReserved.cpu');
echo "memory="$(cat $input | jq -r '.kubeReserved.memory');
echo $'\n';

echo 'eviction threshold';
echo "memory="$(cat $input | jq -r '.evictionHard."memory.available"');

rm $input;