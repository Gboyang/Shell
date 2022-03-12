#!/bin/bash
#
# author: Gboyanghao@163.com
# create bootstrap.kubeconfig 
# ---------------------------------->
k8s_dir=/application/kubernetes/
# 指定kubectl位置
exec_file=$k8s_dir/bin/kubectl
# 指定ca存放位置
ca_file=$k8s_dir/ssl
#-----------------------------------
export BOOTSTRAP_TOKEN=$(head -c 16 /dev/urandom | od -An -t x | tr -d ' ')
cat > token.csv <<EOF
${BOOTSTRAP_TOKEN},kubelet-bootstrap,10001,"system:kubelet-bootstrap"
EOF
# 创建一个变量
export KUBE_APISERVER="https://192.168.1.101:6443"
# 生成bootstrap.kubernetes文件
$exec_file config set-cluster kubernetes \
--certificate-authority=$ca_file/ca.pem \
--embed-certs=true \
--server=${KUBE_APISERVER} \
--kubeconfig=bootstrap.kubeconfig
# -----------------------------
#
$exec_file config set-credentials kubelet-bootstrap --token=${BOOTSTRAP_TOKEN} \
--kubeconfig=bootstrap.kubeconfig
#
#
$exec_file config set-context default --cluster=kubernetes \
--user=kubelet-bootstrap \
--kubeconfig=bootstrap.kubeconfig
#
#
$exec_file config use-context default --kubeconfig=bootstrap.kubeconfig
#
#
$exec_file config set-cluster kubernetes \
--certificate-authority=$ca_file/ca.pem \
--embed-certs=true \
--server=${KUBE_APISERVER} \
--kubeconfig=kube-proxy.kubeconfig
#
# ------------------------------------>
# kube-proxy
$exec_file config set-credentials kube-proxy \
--client-certificate=$ca_file/kube-proxy.pem \
--client-key=$ca_file/kube-proxy-key.pem \
--embed-certs=true \
--kubeconfig=kube-proxy.kubeconfig
#
$exec_file config set-context default \
--cluster=kubernetes \
--user=kube-proxy \
--kubeconfig=kube-proxy.kubeconfig
#
#
$exec_file config use-context default \
--kubeconfig=kube-proxy.kubeconfig 

