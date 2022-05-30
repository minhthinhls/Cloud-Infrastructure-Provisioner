#!/bin/bash

####################################################################################################################################################################
## bash <(curl -s https://raw.githubusercontent.com/minhthinhls/Cloud-Infrastructure-Provisioner/master/CentOS-Stream-8-x64/packages/02-extra-utils-provisioner.sh);
####################################################################################################################################################################

# [HIGHEST PRIORITY] >> Install EPEL Release Package Manager.
sudo yum install epel-release --assumeyes;

# [HIGHEST PRIORITY] >> Install Yum Utils Package Manager.
sudo yum install yum-utils --assumeyes;

# Update the latest Yum Packages
sudo yum update --assumeyes;
sudo yum upgrade --assumeyes;

# Install Utility Packages.
sudo yum install --assumeyes       \
     device-mapper-persistent-data \
     firewalld                     \
     sipcalc                       \
     screen                        \
     lvm2                          \
     net-tools                     \
     npm                           \
     git                           \
     vim                           ;

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @description: For Linode CentOS 8 - DNF Package Manager (Alternative for Yum Package Manager).
# @see {@link https://techglimpse.com/yum-config-manager-command-not-found/}
# @see {@link https://command-not-found.com/yum-config-manager/}
# ----------------------------------------------------------------------------------------------------------------------------------------------------
sudo dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo --assumeyes;

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @description: Set Default Repository and Install Docker Community Edition.
# @description: Make sure `yum-utils` got installed before calling `yum-config-manager`.
# @see {@link https://techglimpse.com/yum-config-manager-command-not-found/}
# @see {@link https://command-not-found.com/yum-config-manager/}
# ----------------------------------------------------------------------------------------------------------------------------------------------------
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo --assumeyes;
sudo yum install --assumeyes \
     docker-ce               \
     docker-ce-cli           \
     containerd.io           ;

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @description: Install `Kube-Context` and `Kube-Environment` for fast command via `Kubectl`.
# @see {@link https://github.com/ahmetb/kubectx/tree/master}
# @see {@link https://www.visualstudiogeeks.com/kubernetes/utilities/using-kubectx-kubens}
# @usage [SWITCH NAMESPACE COMMAND] > kubens <NAMESPACE>
# ----------------------------------------------------------------------------------------------------------------------------------------------------
sudo git clone https://github.com/ahmetb/kubectx /opt/kubectx; # Download Package.
sudo mkdir /root/bin/; # Make Root Bin Directory.
sudo ln -s /opt/kubectx/kubectx /usr/local/bin/kubectx;
sudo ln -s /opt/kubectx/kubens /usr/local/bin/kubens;
sudo ln -s /opt/kubectx/kubectx /root/bin/kubectx;
sudo ln -s /opt/kubectx/kubens /root/bin/kubens;

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @description: Install Kubernetes Repository to the Centos 8 Stream by running the following commands.
# @see {@link https://thecodecloud.in/install-configure-kubernetes-k8s-cluster-centos-8-rhel-8/}
# ----------------------------------------------------------------------------------------------------------------------------------------------------
cat << EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
exclude=kubelet kubeadm kubectl
EOF
sudo yum install --assumeyes      \
     --disableexcludes=kubernetes \
     kubelet                      \
     kubeadm                      \
     kubectl                      ;
