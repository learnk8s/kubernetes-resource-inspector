### Scripts for getting the reserved resources 

- This article explain the resource allocation https://learnk8s.io/allocatable-resources
- This is how we can ssh to the managed nodes https://gist.github.com/danielepolencic/b2b40da7c3157f5bb6c291b48279aba1  
- We can get the total allocatable resources by describing the node `kubectl describe node`  
  

### AKS (Azure Kubernetes Service)

- make sure you have the right kubectl context, you cen run `kubectl get node` to verify
- kubelet service file `/etc/systemd/system/kubelet.service`
```
[Unit]
Description=Kubelet
ConditionPathExists=/usr/local/bin/kubelet
Wants=network-online.target
After=network-online.target

[Service]
Restart=always
EnvironmentFile=/etc/default/kubelet
SuccessExitStatus=143
ExecStartPre=/bin/bash /opt/azure/containers/kubelet.sh
ExecStartPre=/bin/mkdir -p /var/lib/kubelet
ExecStartPre=/bin/mkdir -p /var/lib/cni
ExecStartPre=/bin/bash -c "if [ $(mount | grep \"/var/lib/kubelet\" | wc -l) -le 0 ] ; then /bin/mount --bind /var/lib/kubelet /var/lib/kubelet ; fi"
ExecStartPre=/bin/mount --make-shared /var/lib/kubelet

ExecStartPre=-/sbin/ebtables -t nat --list
ExecStartPre=-/sbin/iptables -t nat --numeric --list

ExecStart=/usr/local/bin/kubelet \
        --enable-server \
        --node-labels="${KUBELET_NODE_LABELS}" \
        --v=2 \
        --volume-plugin-dir=/etc/kubernetes/volumeplugins \
        $KUBELET_TLS_BOOTSTRAP_FLAGS \
        $KUBELET_CONFIG_FILE_FLAGS \
        $KUBELET_CONTAINERD_FLAGS \
        $KUBELET_FLAGS

[Install]
WantedBy=multi-user.target
```
- AKS use flags (KUBELET_FLAGS) instead of config files, you can find the flags in `/etc/default/kubelet`
```
KUBELET_FLAGS=--address=0.0.0.0 --anonymous-auth=false --authentication-token-webhook=true --authorization-mode=Webhook --azure-container-registry-config=/etc/kubernetes/azure.json --cgroups-per-qos=true --client-ca-file=/etc/kubernetes/certs/ca.crt --cloud-provider=external --cluster-dns=10.0.0.10 --cluster-domain=cluster.local --container-log-max-size=50M --enforce-node-allocatable=pods --event-qps=0 --eviction-hard=memory.available<750Mi,nodefs.available<10%,nodefs.inodesFree<5% --feature-gates=CSIMigration=true,CSIMigrationAzureDisk=true,CSIMigrationAzureFile=true,DelegateFSGroupToCSIDriver=true,DisableAcceleratorUsageMetrics=false,DynamicKubeletConfig=false --image-gc-high-threshold=85 --image-gc-low-threshold=80 --keep-terminated-pod-volumes=false --kube-reserved=cpu=100m,memory=1843Mi --kubeconfig=/var/lib/kubelet/kubeconfig --max-pods=110 --node-status-update-frequency=10s --pod-infra-container-image=mcr.microsoft.com/oss/kubernetes/pause:3.6 --pod-manifest-path=/etc/kubernetes/manifests --protect-kernel-defaults=true --read-only-port=0 --resolv-conf=/run/systemd/resolve/resolv.conf --rotate-certificates=true --streaming-connection-idle-timeout=4h --tls-cert-file=/etc/kubernetes/certs/kubeletserver.crt --tls-cipher-suites=TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305,TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384,TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305,TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384,TLS_RSA_WITH_AES_256_GCM_SHA384,TLS_RSA_WITH_AES_128_GCM_SHA256 --tls-private-key-file=/etc/kubernetes/certs/kubeletserver.key 
KUBELET_REGISTER_SCHEDULABLE=true
NETWORK_POLICY=

KUBELET_NODE_LABELS=kubernetes.azure.com/role=agent,agentpool=agentpool,kubernetes.azure.com/agentpool=agentpool,storageprofile=managed,storagetier=Premium_LRS,kubernetes.azure.com/storageprofile=managed,kubernetes.azure.com/storagetier=Premium_LRS,kubernetes.azure.com/os-sku=Ubuntu,kubernetes.azure.com/cluster=MC_664-a59f9d43-create-an-aks-cluster-in-azure-with-t_k8su_cent,kubernetes.azure.com/kubelet-identity-client-id=,kubernetes.azure.com/mode=system,kubernetes.azure.com/node-image-version=AKSUbuntu-1804gen2containerd-2022.08.10
```