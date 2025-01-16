# global systemcontrol (sysctl) configuration

kernel.hostname = $NET__hostname
kernel.domainname = $NET__domain

kernel.printk = 3 4 1 3

net.ipv4.conf.all.forwarding = 0
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.all.secure_redirects = 0
net.ipv4.conf.all.send_redirects = 0

net.ipv4.conf.all.shared_media = 0
net.ipv4.conf.all.rp_filter = 2
net.ipv4.conf.all.log_martians = 1
net.ipv4.conf.all.disable_xfrm = 1
net.ipv4.conf.all.disable_policy = 1

net.ipv4.conf.default.forwarding = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.default.secure_redirects = 0
net.ipv4.conf.default.send_redirects = 0

net.ipv4.conf.default.shared_media = 0
net.ipv4.conf.default.rp_filter = 2
net.ipv4.conf.default.log_martians = 1
net.ipv4.conf.default.disable_xfrm = 1
net.ipv4.conf.default.disable_policy = 1

net.ipv6.conf.all.forwarding = 0

net.ipv4.conf.all.accept_redirects = 0
net.ipv6.conf.all.accept_redirects = 0
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.all.accept_source_route = 0
net.ipv6.conf.all.accept_source_route = 0
net.ipv4.conf.all.log_martians = 1

kernel.ctrl-alt-del = 0
kernel.dmesg_restrict = 1
kernel.panic_on_oops = 1

vm.panic_on_oom = 1

net.ipv4.tcp_timestamps = 1
net.ipv4.tcp_window_scaling = 1
net.ipv4.tcp_sack = 1
net.ipv4.tcp_mtu_probing = 0
net.ipv4.ip_nonlocal_bind = 0
net.ipv4.ip_dynaddr = 0
net.ipv4.tcp_fack = 0
net.ipv4.tcp_ecn = 2
net.ipv4.tcp_dsack = 0
net.ipv4.tcp_slow_start_after_idle = 0

debug.exception-trace = 0

