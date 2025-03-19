#!/usr/bin/env bash

sudo sysctl net.ipv4.conf.all.forwarding=1
sudo iptables -P FORWARD ACCEPT
sudo swapoff -a
sudo ufw disable
sudo ufw status

sudo ip link delete flannel.1 
sudo ip link delete cni0 
sudo rm $HOME/.kube/config

sudo kubeadm reset

sudo rm -r /etc/cni/net.d

sudo su

cat > /etc/containerd/config.toml <<EOF
[plugins."io.containerd.grpc.v1.cri"]
systemd_cgroup = true
EOF
systemctl restart containerd
sleep 10
exit 

sudo kubeadm init --pod-network-cidr=10.244.0.0/16

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml

kubectl get nodes
