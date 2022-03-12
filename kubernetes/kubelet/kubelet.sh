#!/bin/bash

MASTER_ADDRESS=${1:-"192.168.1.101"}
NODE_ADDRESS=${2:-"192.168.1.102"}
DNS_SERVER_IP=${3:-"10.10.0.1"}
DNS_DOMAIN=${4:-"cluster.local"}
KUBECONFIG_DIR=${KUBECONFIG_DIR:-/application/kubernetes/cfg}

cat <<EOF > "${KUBECONFIG_DIR}/kubelet.kubeconfig"
apiVersion: v1
kind: Config
clusters:
  - cluster:
      server: http://${MASTER_ADDRESS}:8080/
    name: local
contexts:
  - context:
      cluster: local
    name: local
current-context: local
EOF

cat <<EOF >/application/kubernetes/cfg/kubelet
# 启用日志标准错误 
KUBE_LOGTOSTDERR="--logtostderr=true"

# 日志级别 
KUBE_LOG_LEVEL="--v=4"

# Kubelet服务IP地址 
NODE_ADDRESS="--address=${NODE_ADDRESS}"

# 自定义节点名称
NODE_HOSTNAME="--hostname-override=${NODE_ADDRESS}"

# kubeconfig路径，指定连接API服务器
KUBELET_KUBECONFIG="--kubeconfig=${KUBECONFIG_DIR}/kubelet.kubeconfig"

# DNS信息
KUBELET_DNS_IP="--cluster-dns=${DNS_SERVER_IP}"
KUBELET_DNS_DOMAIN="--cluster-domain=${DNS_DOMAIN}"

# SWAP
KUBELET_SWAP="--fail-swap-on=false"
EOF

KUBE_PROXY_OPTS="   \${KUBE_LOGTOSTDERR}     \\
                    \${KUBE_LOG_LEVEL}       \\
                    \${NODE_ADDRESS}         \\
                    \${NODE_HOSTNAME}        \\
                    \${KUBELET_KUBECONFIG}   \\
                    \${KUBELET_DNS_IP}       \\
                    \${KUBELET_DNS_DOMAIN}   \\
					\${KUBELET_SWAP}         "

cat <<EOF >/lib/systemd/system/kubelet.service
[Unit]
Description=Kubernetes Kubelet
After=docker.service
Requires=docker.service

[Service]
EnvironmentFile=-/application/kubernetes/cfg/kubelet
ExecStart=/application/kubernetes/bin/kubelet ${KUBE_PROXY_OPTS}
Restart=on-failure
KillMode=process

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable kubelet
systemctl restart kubelet
