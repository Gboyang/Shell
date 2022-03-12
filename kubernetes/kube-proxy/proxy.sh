#!/bin/bash

MASTER_ADDRESS=${1:-"192.168.1.101"}
NODE_ADDRESS=${2:-"192.168.1.102"}

cat <<EOF >/application/kubernetes/cfg/kube-proxy
# 启用日志标准错误 
KUBE_LOGTOSTDERR="--logtostderr=true"

# 日志级别 
KUBE_LOG_LEVEL="--v=4"

# 自定义节点名称
NODE_HOSTNAME="--hostname-override=${NODE_ADDRESS}"

# API服务地址 
KUBE_MASTER="--master=http://${MASTER_ADDRESS}:8080"
EOF

KUBE_PROXY_OPTS="   \${KUBE_LOGTOSTDERR} \\
                    \${KUBE_LOG_LEVEL}   \\
                    \${NODE_HOSTNAME}    \\
                    \${KUBE_MASTER}"

cat <<EOF >/lib/systemd/system/kube-proxy.service
[Unit]
Description=Kubernetes Proxy
After=network.target

[Service]
EnvironmentFile=-/application/kubernetes/cfg/kube-proxy
ExecStart=/application/kubernetes/bin/kube-proxy ${KUBE_PROXY_OPTS}
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable kube-proxy
systemctl restart kube-proxy
