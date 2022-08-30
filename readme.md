### Scripts for getting the reserved resources 

- This article explain the resource allocation https://learnk8s.io/allocatable-resources
- This is how we can ssh to the managed nodes https://gist.github.com/danielepolencic/b2b40da7c3157f5bb6c291b48279aba1  
- We can get the total allocatable resources by describing the node `kubectl describe node`  
- Run the script `inspector.sh` and set your k8s cluster type.

### GKE (Google Kubernetes Engine)

- make sure you have the right kubectl context, you cen run `kubectl get node` to verify
- the script use `yq` command make sure to [install it](https://kislyuk.github.io/yq/#installation).
- kubelet service file `/etc/systemd/system/kubelet.service`
```
[Unit]
Description=Kubernetes kubelet
Requires=network-online.target
After=network-online.target

[Service]
Restart=always
RestartSec=10
EnvironmentFile=/etc/default/kubelet
ExecStart=/home/kubernetes/bin/kubelet $KUBELET_OPTS

[Install]
WantedBy=multi-user.target
```
- GKE store the running command for kubelet with all the flags in `/etc/default/kubelet`
```
KUBELET_OPTS="--v=2 --experimental-check-node-capabilities-before-mount=true --cloud-provider=gce --experimental-mounter-path=/home/kubernetes/containerized_mounter/mounter --cert-dir=/var/lib/kubelet/pki/ --kubeconfig=/var/lib/kubelet/kubeconfig --cni-bin-dir=/home/kubernetes/bin --image-pull-progress-deadline=5m --max-pods=110 --non-masquerade-cidr=0.0.0.0/0 --network-plugin=kubenet --volume-plugin-dir=/home/kubernetes/flexvolume --node-status-max-images=25 --container-runtime=remote --container-runtime-endpoint=unix:///run/containerd/containerd.sock --runtime-cgroups=/system.slice/containerd.service --registry-qps=10 --registry-burst=20 --config /home/kubernetes/kubelet-config.yaml --pod-sysctls='net.core.somaxconn=1024,net.ipv4.conf.all.accept_redirects=0,net.ipv4.conf.all.forwarding=1,net.ipv4.conf.all.route_localnet=1,net.ipv4.conf.default.forwarding=1,net.ipv4.ip_forward=1,net.ipv4.tcp_fin_timeout=60,net.ipv4.tcp_keepalive_intvl=60,net.ipv4.tcp_keepalive_probes=5,net.ipv4.tcp_keepalive_time=300,net.ipv4.tcp_rmem=4096 87380 6291456,net.ipv4.tcp_syn_retries=6,net.ipv4.tcp_tw_reuse=0,net.ipv4.tcp_wmem=4096 16384 4194304,net.ipv4.udp_rmem_min=4096,net.ipv4.udp_wmem_min=4096,net.ipv6.conf.all.disable_ipv6=1,net.ipv6.conf.default.accept_ra=0,net.ipv6.conf.default.disable_ipv6=1,net.netfilter.nf_conntrack_generic_timeout=600,net.netfilter.nf_conntrack_tcp_be_liberal=1,net.netfilter.nf_conntrack_tcp_timeout_close_wait=3600,net.netfilter.nf_conntrack_tcp_timeout_established=86400'"
KUBE_COVERAGE_FILE="/var/log/kubelet.cov"
```
- GKE store the config in the file `/home/kubernetes/kubelet-config.yaml`
```yaml
apiVersion: kubelet.config.k8s.io/v1beta1
authentication:
  anonymous:
    enabled: false
  webhook:
    enabled: true
  x509:
    clientCAFile: /etc/srv/kubernetes/pki/ca-certificates.crt
authorization:
  mode: Webhook
cgroupRoot: /
clusterDNS:
- 10.60.0.10
clusterDomain: cluster.local
enableDebuggingHandlers: true
evictionHard:
  memory.available: 100Mi
  nodefs.available: 10%
  nodefs.inodesFree: 5%
  pid.available: 10%
featureGates:
  CSIMigrationGCE: true
  DynamicKubeletConfig: false
  ExecProbeTimeout: false
  InTreePluginAWSUnregister: true
  InTreePluginAzureDiskUnregister: true
  InTreePluginOpenStackUnregister: true
  InTreePluginvSphereUnregister: true
  RotateKubeletServerCertificate: true
kernelMemcgNotification: true
kind: KubeletConfiguration
kubeReserved:
  cpu: 70m
  ephemeral-storage: 41Gi
  memory: 1736Mi
readOnlyPort: 10255
serverTLSBootstrap: true
staticPodPath: /etc/kubernetes/manifests
```


### EKS (Elastic Kubernetes Service)

- make sure you have the right kubectl context, you cen run `kubectl get node` to verify
- the script use `jq` command make sure to [install it](https://formulae.brew.sh/formula/jq).
- you can customize the reserved resources with [eksctl](https://eksctl.io/usage/customizing-the-kubelet/).
- kubelet service file `/etc/systemd/system/kubelet.service`
```bash
[Unit]
Description=Kubernetes Kubelet
Documentation=https://github.com/kubernetes/kubernetes
After=docker.service iptables-restore.service
Requires=docker.service

[Service]
ExecStartPre=/sbin/iptables -P FORWARD ACCEPT -w 5
ExecStart=/usr/bin/kubelet --cloud-provider aws \
    --config /etc/kubernetes/kubelet/kubelet-config.json \
    --kubeconfig /var/lib/kubelet/kubeconfig \
    --container-runtime docker \
    --network-plugin cni $KUBELET_ARGS $KUBELET_EXTRA_ARGS

Restart=always
RestartSec=5
KillMode=process

[Install]
WantedBy=multi-user.target
```
- EKS store the config in the file `/etc/kubernetes/kubelet/kubelet-config.json`
```json
{
  "kind": "KubeletConfiguration",
  "apiVersion": "kubelet.config.k8s.io/v1beta1",
  "address": "0.0.0.0",
  "authentication": {
    "anonymous": {
      "enabled": false
    },
    "webhook": {
      "cacheTTL": "2m0s",
      "enabled": true
    },
    "x509": {
      "clientCAFile": "/etc/kubernetes/pki/ca.crt"
    }
  },
  "authorization": {
    "mode": "Webhook",
    "webhook": {
      "cacheAuthorizedTTL": "5m0s",
      "cacheUnauthorizedTTL": "30s"
    }
  },
  "clusterDomain": "cluster.local",
  "hairpinMode": "hairpin-veth",
  "readOnlyPort": 0,
  "cgroupDriver": "cgroupfs",
  "cgroupRoot": "/",
  "featureGates": {
    "RotateKubeletServerCertificate": true
  },
  "protectKernelDefaults": true,
  "serializeImagePulls": false,
  "serverTLSBootstrap": true,
  "tlsCipherSuites": [
    "TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256",
    "TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256",
    "TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305",
    "TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384",
    "TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305",
    "TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384",
    "TLS_RSA_WITH_AES_256_GCM_SHA384",
    "TLS_RSA_WITH_AES_128_GCM_SHA256"
  ],
  "clusterDNS": [
    "10.100.0.10"
  ],
  "evictionHard": {
    "memory.available": "100Mi",
    "nodefs.available": "10%",
    "nodefs.inodesFree": "5%"
  },
  "kubeReserved": {
    "cpu": "70m",
    "ephemeral-storage": "1Gi",
    "memory": "574Mi"
  }
}
```

### AKS (Azure Kubernetes Service)

- make sure you have the right kubectl context, you cen run `kubectl get node` to verify
- kubelet service file `/etc/systemd/system/kubelet.service`
```bash
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
```bash
KUBELET_FLAGS=--address=0.0.0.0 --anonymous-auth=false --authentication-token-webhook=true --authorization-mode=Webhook --azure-container-registry-config=/etc/kubernetes/azure.json --cgroups-per-qos=true --client-ca-file=/etc/kubernetes/certs/ca.crt --cloud-provider=external --cluster-dns=10.0.0.10 --cluster-domain=cluster.local --container-log-max-size=50M --enforce-node-allocatable=pods --event-qps=0 --eviction-hard=memory.available<750Mi,nodefs.available<10%,nodefs.inodesFree<5% --feature-gates=CSIMigration=true,CSIMigrationAzureDisk=true,CSIMigrationAzureFile=true,DelegateFSGroupToCSIDriver=true,DisableAcceleratorUsageMetrics=false,DynamicKubeletConfig=false --image-gc-high-threshold=85 --image-gc-low-threshold=80 --keep-terminated-pod-volumes=false --kube-reserved=cpu=100m,memory=1843Mi --kubeconfig=/var/lib/kubelet/kubeconfig --max-pods=110 --node-status-update-frequency=10s --pod-infra-container-image=mcr.microsoft.com/oss/kubernetes/pause:3.6 --pod-manifest-path=/etc/kubernetes/manifests --protect-kernel-defaults=true --read-only-port=0 --resolv-conf=/run/systemd/resolve/resolv.conf --rotate-certificates=true --streaming-connection-idle-timeout=4h --tls-cert-file=/etc/kubernetes/certs/kubeletserver.crt --tls-cipher-suites=TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305,TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384,TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305,TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384,TLS_RSA_WITH_AES_256_GCM_SHA384,TLS_RSA_WITH_AES_128_GCM_SHA256 --tls-private-key-file=/etc/kubernetes/certs/kubeletserver.key 
KUBELET_REGISTER_SCHEDULABLE=true
NETWORK_POLICY=

KUBELET_NODE_LABELS=kubernetes.azure.com/role=agent,agentpool=agentpool,kubernetes.azure.com/agentpool=agentpool,storageprofile=managed,storagetier=Premium_LRS,kubernetes.azure.com/storageprofile=managed,kubernetes.azure.com/storagetier=Premium_LRS,kubernetes.azure.com/os-sku=Ubuntu,kubernetes.azure.com/cluster=MC_664-a59f9d43-create-an-aks-cluster-in-azure-with-t_k8su_cent,kubernetes.azure.com/kubelet-identity-client-id=,kubernetes.azure.com/mode=system,kubernetes.azure.com/node-image-version=AKSUbuntu-1804gen2containerd-2022.08.10
```

### LKE (Linode Kubernetes Engine)

- make sure you have the right kubectl context, you cen run `kubectl get node` to verify
- the script use `yq` command make sure to [install it](https://kislyuk.github.io/yq/#installation).
- kubelet service file `/etc/systemd/system/kubelet.service.d/10-kubeadm.conf`
```bash
# Note: This dropin only works with kubeadm and kubelet v1.11+
[Service]
Environment="KUBELET_KUBECONFIG_ARGS=--bootstrap-kubeconfig=/etc/kubernetes/bootstrap-kubelet.conf --kubeconfig=/etc/kubernetes/kubelet.conf"
Environment="KUBELET_CONFIG_ARGS=--config=/var/lib/kubelet/config.yaml"
# This is a file that "kubeadm init" and "kubeadm join" generates at runtime, populating the KUBELET_KUBEADM_ARGS variable dynamically
EnvironmentFile=-/var/lib/kubelet/kubeadm-flags.env
# This is a file that the user can use for overrides of the kubelet args as a last resort. Preferably, the user should use
# the .NodeRegistration.KubeletExtraArgs object in the configuration files instead. KUBELET_EXTRA_ARGS should be sourced from this file.
EnvironmentFile=-/etc/default/kubelet
ExecStart=
ExecStart=/usr/bin/kubelet $KUBELET_KUBECONFIG_ARGS $KUBELET_CONFIG_ARGS $KUBELET_KUBEADM_ARGS $KUBELET_EXTRA_ARGS
```
- LKE store the config in the file `/var/lib/kubelet/config.yaml`
```yaml
address: 0.0.0.0
apiVersion: kubelet.config.k8s.io/v1beta1
authentication:
  anonymous:
    enabled: false
  webhook:
    cacheTTL: 2m0s
    enabled: true
  x509:
    clientCAFile: /etc/kubernetes/pki/ca.crt
authorization:
  mode: Webhook
  webhook:
    cacheAuthorizedTTL: 5m0s
    cacheUnauthorizedTTL: 30s
cgroupDriver: cgroupfs
cgroupsPerQOS: true
clusterDNS:
- 10.128.0.10
clusterDomain: cluster.local
containerLogMaxFiles: 5
containerLogMaxSize: 10Mi
contentType: application/vnd.kubernetes.protobuf
cpuCFSQuota: true
cpuManagerPolicy: none
cpuManagerReconcilePeriod: 10s
enableControllerAttachDetach: true
enableDebuggingHandlers: true
enforceNodeAllocatable:
- pods
eventBurst: 10
eventRecordQPS: 5
evictionHard:
  imagefs.available: 15%
  memory.available: 100Mi
  nodefs.available: 10%
  nodefs.inodesFree: 5%
evictionPressureTransitionPeriod: 5m0s
failSwapOn: true
featureGates:
  EphemeralContainers: true
  GracefulNodeShutdown: true
fileCheckFrequency: 20s
hairpinMode: promiscuous-bridge
healthzBindAddress: 127.0.0.1
healthzPort: 10248
httpCheckFrequency: 20s
imageGCHighThresholdPercent: 85
imageGCLowThresholdPercent: 80
imageMinimumGCAge: 2m0s
iptablesDropBit: 15
iptablesMasqueradeBit: 14
kind: KubeletConfiguration
kubeAPIBurst: 10
kubeAPIQPS: 5
logging:
  flushFrequency: 0
  options:
    json:
      infoBufferSize: "0"
  verbosity: 0
makeIPTablesUtilChains: true
maxOpenFiles: 1000000
maxPods: 110
memorySwap: {}
nodeStatusReportFrequency: 0s
nodeStatusUpdateFrequency: 10s
oomScoreAdj: -999
podPidsLimit: -1
port: 10250
registryBurst: 10
registryPullQPS: 5
resolvConf: /etc/resolv.conf
rotateCertificates: true
runtimeRequestTimeout: 2m0s
serializeImagePulls: true
shutdownGracePeriod: 30s
shutdownGracePeriodCriticalPods: 10s
staticPodPath: /etc/kubernetes/manifests
streamingConnectionIdleTimeout: 4h0m0s
syncFrequency: 1m0s
volumeStatsAggPeriod: 1m0s
```

### DOKS (DigitalOcean Kubernetes Service)

- make sure you have the right kubectl context, you cen run `kubectl get node` to verify
- the script use `yq` command make sure to [install it](https://kislyuk.github.io/yq/#installation).
- kubelet service file `/etc/systemd/system/kubelet.service`
```bash
[Unit]
Description=Kubernetes Kubelet Server
Documentation=https://kubernetes.io/docs/concepts/overview/components/#kubelet

[Service]
OOMScoreAdjust=-999

ExecStart=/usr/bin/kubelet \
  --config=/etc/kubernetes/kubelet.conf \
  --logtostderr=true \
  --kubeconfig=/etc/kubernetes/kubelet.kubeconfig \
  --bootstrap-kubeconfig=/etc/kubernetes/bootstrap.kubeconfig \
  --register-node=true \
  --node-labels="doks.digitalocean.com/node-id=4f2b99f0-9ebd-47a5-a954-efd61779f143,doks.digitalocean.com/node-pool-id=f6e0de05-2336-4a06-834c-d02faec8006c,doks.digitalocean.com/node-pool=pool-1pvhk09r2,doks.digitalocean.com/version=1.23.9-do.0" \
  --root-dir=/var/lib/kubelet \
  --v=2 \
  --cloud-provider=external \
  --node-ip="10.106.0.2" \
  --container-runtime=remote \
  --container-runtime-endpoint=unix:///run/containerd/containerd.sock

Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
```
- DOKS store the config in the file `/etc/kubernetes/kubelet.conf`
```yaml
kind: KubeletConfiguration
providerID: "digitalocean://314476419"
apiVersion: kubelet.config.k8s.io/v1beta1
staticPodPath: "/etc/kubernetes/manifests"
rotateCertificates: true
authentication:
  anonymous:
    enabled: false
  webhook:
    enabled: true
  x509:
    clientCAFile: "/etc/kubernetes/ca.pem"
authorization:
  mode: AlwaysAllow
runtimeRequestTimeout: "15m"
clusterDomain: cluster.local
clusterDNS:
  - 10.245.0.10
kubeReserved:
  memory: "369432Ki"
  cpu: "100m"
  pid: "1024"
evictionHard:
  memory.available: "51200Ki"
  pid.available: 10%
  # The nodefs and imagefs reference the same fs in DOKS, but the reason
  # for the eviction matters in how its handled. Images will only be cleaned
  # if the imagefs limits are hit.
  imagefs.inodesFree: 6%
  # Note: these are the defaults, but spelled out here for clarity.
  nodefs.available: 10%
  nodefs.inodesFree: 5%
  imagefs.available: 15%
serverTLSBootstrap: true
serializeImagePulls: false
# Delay node shutdown for 30s to give pods time to terminate gracefully. Normal
# pods will be shut down during the first 20s, then critical pods will have 10s.
shutdownGracePeriod: 30s
shutdownGracePeriodCriticalPods: 10s
```