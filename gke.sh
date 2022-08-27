#!/bin/bash
node=$(kubectl get node -o name | head -n 1)
file="/host/home/kubernetes/kubelet-config.yaml"
input="./.gke.yaml"
kubectl debug "$node" -it  --image xxradar/hackon -- cat $file | tail -n +2 > $input;

echo 'os reserved'
echo 'cpu=100m';
echo 'memory=100Mi';
echo $'\n';

echo 'kubelet reserved:';
echo "cpu="$(cat $input | yq -r '.kubeReserved.cpu');
echo "memory="$(cat $input | yq -r '.kubeReserved.memory');
echo $'\n';

echo 'eviction threshold';
echo "memory="$(cat $input | yq -r '.evictionHard."memory.available"');

rm $input;