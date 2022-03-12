#!/bin/bash
#
# iptables

iptables -F
iptables -X
iptables -Z

# 默认规则
iptables -P INPUT DROP
iptables -P OUTPUT ACCEPT
iptables -P FORWARD DROP

# bond2 管理
iptables -i bond2 -I INPUT -m iprange --src-range 10.242.11.66-10.242.11.69   -j ACCEPT
iptables -i bond2 -I INPUT -p tcp -m multiport --dport 22,8056  -j ACCEPT
iptables -i bond2 -I INPUT -p udp --dport 123  -j ACCEPT

# bond0  业务
iptables -i bond0 -I INPUT -m iprange  --src-range 10.242.51.65-10.242.51.68   -j ACCEPT
iptables -i bond0 -I INPUT -p tcp -m multiport –dport 22,3260   -j ACCEPT

# bond1 内部集群网络
iptables -i bond1  -p tcp -j ACCEPT

iptables-save 