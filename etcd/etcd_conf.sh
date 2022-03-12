#!/bin/sh
#
# create etcd config file and systemd file
# author: Gboyanghao@163.com
# ----------------------------------------
# install dir
in_dir=/application/kubernetes
# data
ETCD_DATA_DIR=$in_dir/data
DEVICE_ETCX=${1:-"etcd01"}
ADDRESS_IP=${2:-"192.168.1.101"}
CLUSTER_IP1=${3:-"192.168.1.102"}
CLUSTER_IP2=${4:-"192.168.1.103"}
# ----------------------------------------
# create etcd config file
cat >>$in_dir/cfs/etcd <<EOF
#[Member]
ETCD_NAME="${DEVICE_ETCX}"
ETCD_DATA_DIR="${ETCD_DATA_DIR}"
ETCD_LISTEN_PEER_URLS="https://${ADDRESS_IP}:2380"
ETCD_LISTEN_CLIENT_URLS="https://${ADDRESS_IP}:2379"

#[Clustering]
ETCD_INITIAL_ADVERTISE_PEER_URLS="https://${ADDRESS_IP}:2380"
ETCD_ADVERTISE_CLIENT_URLS="https://${ADDRESS_IP}:2379"
ETCD_INITIAL_CLUSTER="etcd01=https://${ADDRESS_IP}:2380,etcd02=https://${CLUSTER_IP1}:2380,etcd03=https://${CLUSTER_IP2}:2380"
ETCD_INITIAL_CLUSTER_TOKEN="etcd-cluster"
ETCD_INITIAL_CLUSTER_STATE="new"
EOF
mkdir -p $ETCD_DATA_DIR
# create systemd file
cat >/usr/lib/systemd/system/etcd.service <<EOF
[Unit]
Description=Etcd Server
After=network.target
After=network-online.target
Wants=network-online.target

[Service]
Type=notify
WorkingDirectory=${ETCD_DATA_DIR}
EnvironmentFile=${in_dir}/cfs/etcd
ExecStart=${in_dir}/bin/etcd \\
--name=\${ETCD_NAME} \\
--data-dir=\${ETCD_DATA_DIR} \\
--listen-peer-urls=\${ETCD_LISTEN_PEER_URLS} \\
--listen-client-urls=\${ETCD_LISTEN_CLIENT_URLS},http://127.0.0.1:2379 \\
--advertise-client-urls=\${ETCD_ADVERTISE_CLIENT_URLS} \\
--initial-advertise-peer-urls=\${ETCD_INITIAL_ADVERTISE_PEER_URLS} \\
--initial-cluster=\${ETCD_INITIAL_CLUSTER} \\
--initial-cluster-token=\${ETCD_INITIAL_CLUSTER_TOKEN} \\
--initial-cluster-state=new \\
--cert-file=${in_dir}/ssl/server.pem \\
--key-file=${in_dir}/ssl/server-key.pem \\
--peer-cert-file=${in_dir}/ssl/server.pem \\
--peer-key-file=${in_dir}/ssl/server-key.pem \\
--trusted-ca-file=${in_dir}/ssl/ca.pem \\
--peer-trusted-ca-file=${in_dir}/ssl/ca.pem
Restart=on-failure
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF