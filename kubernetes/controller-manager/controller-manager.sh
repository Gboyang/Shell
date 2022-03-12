#!/bin/bash

MASTER_ADDRESS=${1:-"192.168.1.101"}

cat <<EOF >/application/kubernetes/cfg/kube-controller-manager
KUBE_LOGTOSTDERR="--logtostderr=true"
KUBE_LOG_LEVEL="--v=4"
KUBE_MASTER="--master=${MASTER_ADDRESS}:8080"

# 在执行主循环之前，先选举一个leader。高可用性运行组件时启用此功能，默认true 
KUBE_LEADER_ELECT="--leader-elect"
EOF

KUBE_CONTROLLER_MANAGER_OPTS="  \${KUBE_LOGTOSTDERR} \\
                                \${KUBE_LOG_LEVEL}   \\
 				\${KUBE_MASTER}      \\
                                \${KUBE_LEADER_ELECT}"

cat <<EOF >/lib/systemd/system/kube-controller-manager.service
[Unit]
Description=Kubernetes Controller Manager
Documentation=https://github.com/kubernetes/kubernetes

[Service]
EnvironmentFile=-/application/kubernetes/cfg/kube-controller-manager
ExecStart=/application/kubernetes/bin/kube-controller-manager ${KUBE_CONTROLLER_MANAGER_OPTS}
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable kube-controller-manager
systemctl restart kube-controller-manager
