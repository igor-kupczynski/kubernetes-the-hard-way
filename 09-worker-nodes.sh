# === Run on ALL the controller nodes ===
export NODE_NAME=$(hostname -s | awk -F '-' '{ print "worker-"$(NF)}'); echo $NODE_NAME

# Configure internal routing
{
  echo "127.0.0.1 ${NODE_NAME}" | sudo tee -a /etc/hosts
  echo "10.240.0.20 worker-0" | sudo tee -a /etc/hosts
  echo "10.240.0.21 worker-1" | sudo tee -a /etc/hosts
  echo "10.240.0.22 worker-2" | sudo tee -a /etc/hosts
  echo "10.240.0.10 controller-0" | sudo tee -a /etc/hosts
  echo "10.240.0.11 controller-1" | sudo tee -a /etc/hosts
  echo "10.240.0.12 controller-2" | sudo tee -a /etc/hosts
}

# Prepare the nodes
{
  sudo apt-get update
  sudo apt-get -y install socat conntrack ipset
}


# Download and worker install binaries
export CRI_VER="v1.20.0"
export RUNC_VER="v1.0.0-rc93"
export CNI_VER="v0.9.1"
export CONTAINERD_VER="1.4.4"  # v.. is skipped on purpose
export K8S_VER="v1.20.4"

wget -q --show-progress --https-only --timestamping \
  "https://github.com/kubernetes-sigs/cri-tools/releases/download/${CRI_VER}/crictl-${CRI_VER}-linux-amd64.tar.gz" \
  "https://github.com/opencontainers/runc/releases/download/${RUNC_VER}/runc.amd64" \
  "https://github.com/containernetworking/plugins/releases/download/${CNI_VER}/cni-plugins-linux-amd64-${CNI_VER}.tgz" \
  "https://github.com/containerd/containerd/releases/download/v${CONTAINERD_VER}/containerd-${CONTAINERD_VER}-linux-amd64.tar.gz" \
  "https://storage.googleapis.com/kubernetes-release/release/${K8S_VER}/bin/linux/amd64/kubectl" \
  "https://storage.googleapis.com/kubernetes-release/release/${K8S_VER}/bin/linux/amd64/kube-proxy" \
  "https://storage.googleapis.com/kubernetes-release/release/${K8S_VER}/bin/linux/amd64/kubelet"


sudo mkdir -p \
  /etc/cni/net.d \
  /opt/cni/bin \
  /var/lib/kubelet \
  /var/lib/kube-proxy \
  /var/lib/kubernetes \
  /var/run/kubernetes

{
  mkdir containerd
  tar -xvf "crictl-${CRI_VER}-linux-amd64.tar.gz"
  tar -xvf "containerd-${CONTAINERD_VER}-linux-amd64.tar.gz" -C containerd
  sudo tar -xvf "cni-plugins-linux-amd64-${CNI_VER}.tgz" -C /opt/cni/bin/
  sudo mv runc.amd64 runc
  chmod +x crictl kubectl kube-proxy kubelet runc 
  sudo mv crictl kubectl kube-proxy kubelet runc /usr/local/bin/
  sudo mv containerd/bin/* /bin/
}

# Configure CNI networking
{
  export POD_CIDR=$(curl -s -H "Metadata-Flavor: Google" \
    http://metadata.google.internal/computeMetadata/v1/instance/attributes/pod-cidr)
  echo $POD_CIDR
}

cat <<EOF | sudo tee /etc/cni/net.d/10-bridge.conf
{
    "cniVersion": "0.3.1",
    "name": "bridge",
    "type": "bridge",
    "bridge": "cnio0",
    "isGateway": true,
    "ipMasq": true,
    "ipam": {
        "type": "host-local",
        "ranges": [
          [{"subnet": "${POD_CIDR}"}]
        ],
        "routes": [{"dst": "0.0.0.0/0"}]
    }
}
EOF

cat <<EOF | sudo tee /etc/cni/net.d/99-loopback.conf
{
    "cniVersion": "0.3.1",
    "name": "lo",
    "type": "loopback"
}
EOF


# Configure containerd
sudo mkdir -p /etc/containerd/

cat << EOF | sudo tee /etc/containerd/config.toml
[plugins]
  [plugins.cri.containerd]
    snapshotter = "overlayfs"
    [plugins.cri.containerd.default_runtime]
      runtime_type = "io.containerd.runtime.v1.linux"
      runtime_engine = "/usr/local/bin/runc"
      runtime_root = ""
EOF

cat <<EOF | sudo tee /etc/systemd/system/containerd.service
[Unit]
Description=containerd container runtime
Documentation=https://containerd.io
After=network.target

[Service]
ExecStartPre=/sbin/modprobe overlay
ExecStart=/bin/containerd
Restart=always
RestartSec=5
Delegate=yes
KillMode=process
OOMScoreAdjust=-999
LimitNOFILE=1048576
LimitNPROC=infinity
LimitCORE=infinity

[Install]
WantedBy=multi-user.target
EOF


# Configure the Kubelet
{
  sudo mv ${NODE_NAME}-key.pem ${NODE_NAME}.pem /var/lib/kubelet/
  sudo mv ${NODE_NAME}.kubeconfig /var/lib/kubelet/kubeconfig
  sudo mv ca.pem /var/lib/kubernetes/
}

cat <<EOF | sudo tee /var/lib/kubelet/kubelet-config.yaml
kind: KubeletConfiguration
apiVersion: kubelet.config.k8s.io/v1beta1
authentication:
  anonymous:
    enabled: false
  webhook:
    enabled: true
  x509:
    clientCAFile: "/var/lib/kubernetes/ca.pem"
authorization:
  mode: Webhook
clusterDomain: "cluster.local"
clusterDNS:
  - "10.32.0.10"
podCIDR: "${POD_CIDR}"
resolvConf: "/run/systemd/resolve/resolv.conf"
runtimeRequestTimeout: "15m"
tlsCertFile: "/var/lib/kubelet/${NODE_NAME}.pem"
tlsPrivateKeyFile: "/var/lib/kubelet/${NODE_NAME}-key.pem"
EOF

cat <<EOF | sudo tee /etc/systemd/system/kubelet.service
[Unit]
Description=Kubernetes Kubelet
Documentation=https://github.com/kubernetes/kubernetes
After=containerd.service
Requires=containerd.service

[Service]
ExecStart=/usr/local/bin/kubelet \\
  --config=/var/lib/kubelet/kubelet-config.yaml \\
  --container-runtime=remote \\
  --container-runtime-endpoint=unix:///var/run/containerd/containerd.sock \\
  --hostname-override=${NODE_NAME} \\
  --image-pull-progress-deadline=2m \\
  --kubeconfig=/var/lib/kubelet/kubeconfig \\
  --network-plugin=cni \\
  --register-node=true \\
  --v=2
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF


# Configure the Kubernetes Proxy
sudo mv kube-proxy.kubeconfig /var/lib/kube-proxy/kubeconfig

cat <<EOF | sudo tee /var/lib/kube-proxy/kube-proxy-config.yaml
kind: KubeProxyConfiguration
apiVersion: kubeproxy.config.k8s.io/v1alpha1
clientConnection:
  kubeconfig: "/var/lib/kube-proxy/kubeconfig"
mode: "iptables"
clusterCIDR: "10.200.0.0/16"
EOF

cat <<EOF | sudo tee /etc/systemd/system/kube-proxy.service
[Unit]
Description=Kubernetes Kube Proxy
Documentation=https://github.com/kubernetes/kubernetes

[Service]
ExecStart=/usr/local/bin/kube-proxy \\
  --config=/var/lib/kube-proxy/kube-proxy-config.yaml
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF


# Start the services
{
  sudo systemctl daemon-reload
  sudo systemctl enable containerd kubelet kube-proxy
  sudo systemctl start containerd kubelet kube-proxy
}


# === Run from your workstation ===

# Verify
gcloud compute ssh igor-learn-k8s-controller-0 --command "kubectl get nodes --kubeconfig admin.kubeconfig"
