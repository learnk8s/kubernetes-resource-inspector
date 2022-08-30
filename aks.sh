#!/bin/bash
node=$(kubectl get node -o name | head -n 1)
file="/host/etc/default/kubelet"
input=$(kubectl debug "$node" -it  --image xxradar/hackon -- cat $file)

echo 'os reserved:'
echo 'cpu=100m';
echo 'memory=100Mi';
echo $'\n';

echo 'kubelet reserved:';
echo $input | tr ' ' '\n' | grep 'kube-reserved' | cut -d '=' -f 2,3,4,5 | tr ',' '\n';
echo $'\n';

echo 'eviction threshold:';
echo "memory="$(echo $input | tr ' ' '\n' | grep 'eviction-hard' |  cut -d '=' -f 2 | cut -d ',' -f 1 | cut -d '<' -f 2)
