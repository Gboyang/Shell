# PXE安装脚本说明
本脚本可对CentOS7或者以上版本及openEuler系统

# 使用说明
1、第一步：修改config/pxe.conf（更加自己IP地址范围修改）
network_segment=10.41.79.0     # 网段
network_mask=255.255.255.0     # 掩码
start_range=10.41.79.10        # 开始取值范围
end_range=10.41.79.15          # 结束取值范围
next_server=10.41.79.201       # 下个服务地址
network_gateway=10.41.79.254   # 网关地址

local_YUM_Dir=/mnt             # 配置本地yum指定的挂载点

2、将拿到此安装脚本，需要检查iso目录下是否有openEuler-xxx.iso文件，以及config下是否有grup.cfg文件

3、执行cd pxe_install_v2这里一定要进入目录后执行sh install

注意：当你运行脚本后可能会出现ERROR: check network_segment ip address legitimacy错误。出现该错误有两种可能性
	1、network_segment 地址没有配正确
	
	2、少ipcalc工具执行执行yum -y install ipcalc安装再次执行脚本即可（脚本失败后本地yum源已经配好）


# 脚本尚在完善当中，有问题可联系作者：Gboyanghao@163.com