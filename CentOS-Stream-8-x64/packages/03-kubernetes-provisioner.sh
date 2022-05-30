#!/bin/bash

###################################################################################################################################################################
## bash <(curl -s https://raw.githubusercontent.com/minhthinhls/Cloud-Infrastructure-Provisioner/master/CentOS-Stream-8-x64/packages/03-kubernetes-provisioner.sh);
###################################################################################################################################################################

####################################################################################################
###### REFERENCE: https://github.com/zokeber/terraform-ec2-centos7-docker/blob/HEAD/script.sh ######
####################################################################################################

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @description: Disable SWAP for Kubernetes Installation by running the following Commands.
# @see {@link https://www.howtoforge.com/tutorial/centos-kubernetes-docker-cluster/}
# ----------------------------------------------------------------------------------------------------------------------------------------------------
sudo swapoff -a;
sudo sed -i '/ swap / s/^\(.*\)$/# \1/g' /etc/fstab; # [Comment & Disable] Swap Line.

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @description: Setup hostname; Disable SELinux; Configure firewall rules.
# @see {@link https://www.howtoforge.com/tutorial/centos-kubernetes-docker-cluster/}
# @see {@link https://thecodecloud.in/install-configure-kubernetes-k8s-cluster-centos-8-rhel-8/}
# ----------------------------------------------------------------------------------------------------------------------------------------------------
sudo setenforce 0;
sudo sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config;
sudo sed -i --follow-symlinks 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux;

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @description: Configure Firewall Rules. Must provide Root Privileges.
# @see {@link https://www.digitalocean.com/community/tutorials/how-to-set-up-a-firewall-using-firewalld-on-centos-8}
# ----------------------------------------------------------------------------------------------------------------------------------------------------
sudo yum install firewalld -y;
sudo systemctl start firewalld;
sudo systemctl enable firewalld;
firewall-cmd --state;

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @description: Configure Firewall Rules. Must provide Root Privileges.
# @see {@link https://thecodecloud.in/install-configure-kubernetes-k8s-cluster-centos-8-rhel-8/}
# ----------------------------------------------------------------------------------------------------------------------------------------------------
firewall-cmd --permanent --zone=public --add-masquerade;
firewall-cmd --permanent --zone=public \
--add-port=4789/udp \
--add-port=6443/tcp \
--add-port=7946/udp \
--add-port=10250/tcp \
--add-port=10251/tcp \
--add-port=10252/tcp \
--add-port=10255/tcp \
--add-port=2375-2377/tcp \
--add-port=2379-2380/tcp \
--add-port=30000-32767/tcp; # Kubernetes Cluster [Node Ports] Services.

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @description: Configure Firewall Rules. Provide Family Rule Sets for Cluster Nodes.
# @see {@link https://thecodecloud.in/install-configure-kubernetes-k8s-cluster-centos-8-rhel-8/}
# @example [PROVISION CLUSTER FAMILY RULE] > firewall-cmd --zone=public --permanent --add-rich-rule 'rule family=ipv4 source address=worker-IP-address/32 accept';
# ----------------------------------------------------------------------------------------------------------------------------------------------------
firewall-cmd --zone=public --permanent --add-rich-rule 'rule family=ipv4 source address=16.162.187.196/32 accept';
firewall-cmd --zone=public --permanent --add-rich-rule 'rule family=ipv4 source address=139.162.11.193/32 accept';
firewall-cmd --zone=public --permanent --add-rich-rule 'rule family=ipv4 source address=139.177.186.140/32 accept';
firewall-cmd --zone=public --permanent --add-rich-rule 'rule family=ipv4 source address=128.199.166.44/32 accept';
firewall-cmd --zone=public --permanent --add-rich-rule 'rule family=ipv4 source address=159.223.50.252/32 accept';
firewall-cmd --zone=public --permanent --add-rich-rule 'rule family=ipv4 source address=167.172.89.209/32 accept';
firewall-cmd --zone=public --permanent --add-rich-rule 'rule family=ipv4 source address=10.104.0.0/20 accept'; # Digital Ocean Private Network.
firewall-cmd --zone=public --permanent --add-rich-rule 'rule family=ipv4 source address=10.244.0.0/16 accept'; # Flannel Discover Pods Network.
firewall-cmd --reload;
firewall-cmd --list-all;

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @description: Forwarding IPv4 and letting iptables see bridged traffic.
# @see {@link https://kubernetes.io/docs/setup/production-environment/container-runtimes/}
# ----------------------------------------------------------------------------------------------------------------------------------------------------
cat << EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @description: Setup Kubernetes Cluster System Controller.
# @see {@link https://www.datapacket.com/blog/build-kubernetes-cluster}
# ----------------------------------------------------------------------------------------------------------------------------------------------------
cat << EOF | sudo tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @description: Setup Kubernetes Cluster Network using the Flannel Network Add-on.
# @see {@link https://dzone.com/articles/configure-kubernetes-network-with-flannel}
# ----------------------------------------------------------------------------------------------------------------------------------------------------
sudo cp /etc/sysctl.conf /etc/sysctl.conf.backup;
cat << EOF | sudo tee /etc/sysctl.conf
net.bridge.bridge-nf-call-iptables = 1
EOF

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @description: Setup Kubernetes Cluster System Controller.
# @see {@link https://www.datapacket.com/blog/build-kubernetes-cluster}
# ----------------------------------------------------------------------------------------------------------------------------------------------------
cat << EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
EOF

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @description: Setup Kubernetes Cluster System Controller.
# @see {@link https://www.datapacket.com/blog/build-kubernetes-cluster}
# ----------------------------------------------------------------------------------------------------------------------------------------------------
cat << EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
EOF

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @description: Enable br_netfilter Kernel Module.
# @see {@link https://www.tecmint.com/install-a-kubernetes-cluster-on-centos-8/}
# @see {@link https://thecodecloud.in/install-configure-kubernetes-k8s-cluster-centos-8-rhel-8/}
# ----------------------------------------------------------------------------------------------------------------------------------------------------
sysctl net.bridge.bridge-nf-call-iptables=1;

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @description: Enable br_netfilter Kernel Module.
# @see {@link https://www.tecmint.com/install-a-kubernetes-cluster-on-centos-8/}
# @see {@link https://thecodecloud.in/install-configure-kubernetes-k8s-cluster-centos-8-rhel-8/}
# ----------------------------------------------------------------------------------------------------------------------------------------------------
sudo modprobe overlay;
sudo modprobe br_netfilter;
sudo lsmod | grep br_netfilter; # Double Check on Logging.
echo '1' > /proc/sys/net/bridge/bridge-nf-call-iptables;
cat /proc/sys/net/bridge/bridge-nf-call-iptables;
# Apply `sysctl` params without Reboot.
sudo sysctl --load --system;

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @description: Reboot Virtual Machines. Then login and start the Services, Docker and Kubelet.
# @see {@link https://thecodecloud.in/install-configure-kubernetes-k8s-cluster-centos-8-rhel-8/}
# ----------------------------------------------------------------------------------------------------------------------------------------------------
kubeadm config images pull;
systemctl start docker && systemctl enable --now docker;
systemctl start kubelet && systemctl enable --now kubelet;

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @description: Apply Container Network Interface.
# @see {@link https://serverfault.com/questions/877136/debug-kubelet-not-starting/888411#888411}
# ----------------------------------------------------------------------------------------------------------------------------------------------------
cat << EOF > /etc/docker/daemon.json
{
  "exec-opts": ["native.cgroupdriver=systemd"]
}
EOF

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @description: Resolve Error [ERROR CRI]: Container Runtime is not Running. Apply to all Cluster Nodes.
# @description: Apply these [COMMAND] after deploying & linking Kubernetes Cluster.
# @see {@link https://github.com/containerd/containerd/issues/4581}
# ----------------------------------------------------------------------------------------------------------------------------------------------------
sudo rm -rf /etc/containerd/config.toml;
systemctl restart containerd;

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @description: No networks found in `/etc/cni/net.d`.
# @see {@link https://github.com/kubernetes/kubernetes/issues/54918#issuecomment-408278160}
# @description: Due to the proxy issues. Kubelet cannot connect to the kube-api-server through configured HTTP Proxy.
# @see {@link https://github.com/kubernetes/kubernetes/issues/54918#issuecomment-385162637}
# ----------------------------------------------------------------------------------------------------------------------------------------------------
chmod -R +r /etc/cni/net.d/;
