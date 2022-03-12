#!/bin/bash

MASTER_ADDRESS=${1:-"192.168.1.101"}
ETCD_SERVERS=${2:-"http://192.168.1.101:2379"}
SERVICE_CLUSTER_IP_RANGE=${3:-"10.10.0.0/24"}
ADMISSION_CONTROL=${4:-""}

cat <<EOF >/application/kubernetes/cfg/kube-apiserver
# 启用日志标准错误 
KUBE_LOGTOSTDERR="--logtostderr=true"

# 日志级别
KUBE_LOG_LEVEL="--v=4"

# Etcd服务地址
KUBE_ETCD_SERVERS="--etcd-servers=${ETCD_SERVERS}"

# 指定Etcd版本，默认etcd3
KUBE_ETCD_VERSION="--storage-backend=etcd3"

# API服务监听地址
KUBE_API_ADDRESS="--insecure-bind-address=0.0.0.0"

# API服务监听端口
KUBE_API_PORT="--insecure-port=8080"

# Kubelet端口
NODE_PORT="--kubelet-port=10250"

# 对集群中成员提供API服务地址
KUBE_ADVERTISE_ADDR="--advertise-address=${MASTER_ADDRESS}"

# 允许容器请求特权模式，默认false
KUBE_ALLOW_PRIV="--allow-privileged=false"

# 集群分配的IP范围
KUBE_SERVICE_ADDRESSES="--service-cluster-ip-range=${SERVICE_CLUSTER_IP_RANGE}"

# 控制资源进入集群, 默认AlwaysAdmit
# Comma-delimited list of:
#   LimitRanger, AlwaysDeny, SecurityContextDeny, NamespaceExists,
#   NamespaceLifecycle, NamespaceAutoProvision, AlwaysAdmit,
#   ServiceAccount, DefaultStorageClass, DefaultTolerationSeconds, ResourceQuota
KUBE_ADMISSION_CONTROL="--admission-control=${ADMISSION_CONTROL}"

EOF

KUBE_APISERVER_OPTS="   \${KUBE_LOGTOSTDERR}         \\
                        \${KUBE_LOG_LEVEL}           \\
                        \${KUBE_ETCD_SERVERS}        \\
                        \${KUBE_ETCD_VERSION}        \\
                        \${KUBE_API_ADDRESS}         \\
                        \${KUBE_API_PORT}            \\
                        \${NODE_PORT}                \\
                        \${KUBE_ADVERTISE_ADDR}      \\
                        \${KUBE_ALLOW_PRIV}          \\
                        \${KUBE_SERVICE_ADDRESSES}"

cat <<EOF >/lib/systemd/system/kube-apiserver.service
[Unit]
Description=Kubernetes API Server
Documentation=https://github.com/kubernetes/kubernetes

[Service]
EnvironmentFile=-/application/kubernetes/cfg/kube-apiserver
ExecStart=/application/kubernetes/bin/kube-apiserver ${KUBE_APISERVER_OPTS}
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable kube-apiserver
systemctl restart kube-apiserver
