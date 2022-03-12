#!/bin/bash
# 
# create flannel config file and systemd file
# author: Gboyanghao@163.com
#------------------------------------
# install_dir
install_dir=/application/kubernetes
# flanneld path
flannel_exec=$install_dir/bin/flanneld
# ssl path
ssl_dir=$install_dir/ssl
#------------------------------------
# create flannel file
# --etcd-endpoints=https://192.168.1.101:2379,https://192.168.1.102:2379,https://192.168.1.103:2379 根据自己情况修改
cat >>$install_dir/cfs/flannel <<EOF
FLANNEL_OPTIONS="--etcd-endpoints=https://192.168.1.101:2379,https://192.168.1.102:2379,https://192.168.1.103:2379 \\
-etcd-cafile=${ssl_dir}/ca.pem \\
-etcd-certfile=${ssl_dir}/server.pem \\
-etcd-keyfile=${ssl_dir}/server-key.pem"
EOF
# create flannel systemd file
cat >>/usr/lib/systemd/system/flanneld.service <<EOF 
[Unit]
Description=Flanneld overlay address etcd agent
After=network-online.target network.target
Before=docker.service

[Service]
Type=notify
EnvironmentFile=${install_dir}/cfs/flannel
ExecStart=${flannel_exec} --ip-masq \$FLANNEL_OPTIONS
ExecStartPost=${install_dir}/bin/mk-docker-opts.sh -k DOCKER_NETWORK_OPTIONS -d /run/flannel/subnet.env
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF