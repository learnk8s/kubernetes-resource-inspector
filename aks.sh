#!/bin/bash
node=$(kubectl get node -o name | head -n 1)
file="/host/etc/default/kubelet"
input=$(kubectl debug "$node" -it  --image xxradar/hackon -- cat $file)
node_info=$(kubectl get $node -o json);

echo 'total capacity:'
echo "cpu="$(echo $node_info | jq -r '.status.capacity.cpu // 0');
echo "memory="$(echo $node_info | jq -r '.status.capacity.memory // 0');
echo $'\n';

echo 'total allocatable:'
echo "cpu="$(echo $node_info | jq -r '.status.allocatable.cpu // 0');
echo "memory="$(echo $node_info | jq -r '.status.allocatable.memory // 0');
echo $'\n';

echo 'system reserved:'
echo $input | tr ' ' '\n' | grep 'system-reserved' | cut -d '=' -f 2,3,4,5 | tr ',' '\n';
echo $'\n';

echo 'kubelet reserved:';
echo $input | tr ' ' '\n' | grep 'kube-reserved' | cut -d '=' -f 2,3,4,5 | tr ',' '\n';
echo $'\n';

echo 'eviction threshold:';
echo "memory="$(echo $input | tr ' ' '\n' | grep 'eviction-hard' |  cut -d '=' -f 2 | cut -d ',' -f 1 | cut -d '<' -f 2)
