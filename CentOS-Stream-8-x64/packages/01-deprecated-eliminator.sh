#!/bin/bash

##################################################################################################################################################################
## bash <(curl -s https://raw.githubusercontent.com/minhthinhls/Cloud-Infrastructure-Provisioner/master/CentOS-Stream-8-x64/packages/01-deprecated-eliminator.sh);
##################################################################################################################################################################

####################################################################################################
###### REFERENCE: https://github.com/zokeber/terraform-ec2-centos7-docker/blob/HEAD/script.sh ######
####################################################################################################

# Uninstall duplicated Docker Installation.
sudo yum remove --assumeyes  \
     docker                  \
     docker-client           \
     docker-client-latest    \
     docker-common           \
     docker-engine           \
     docker-latest           \
     docker-latest-logrotate \
     docker-logrotate        \
     docker-selinux          ;

# =============================================================================== #
#                  New Generation of Container Management Tools                   #
# @see {@link https://www.redhat.com/en/blog/say-hello-buildah-podman-and-skopeo} #
# =============================================================================== #

# Uninstall [Run-Container] && its dependency [Pod-man]
# Because [Docker] will conflict with [Pod-man] on RHEL v8
# @see {@link https://access.redhat.com/discussions/5895421#comment-2066741}
sudo yum remove runc --assumeyes;
sudo dnf remove runc --assumeyes;

# Remove [Run-Container], [Pod-man], [Build-ah] and other packages that conflict with Docker.
sudo yum remove @container-tools --assumeyes;
sudo dnf remove @container-tools --assumeyes;
