VERSION=1.7.15
PLATFORM=amd64
wget https://github.com/containerd/containerd/releases/download/v$VERSION/containerd-$VERSION-linux-$PLATFORM.tar.gz
sudo tar Cxzvf /usr/local containerd-$VERSION-linux-$PLATFORM.tar.gz

wget https://raw.githubusercontent.com/containerd/containerd/main/containerd.service
sudo mkdir -p /usr/local/lib/systemd/system/
sudo mv containerd.service /usr/local/lib/systemd/system/


sudo systemctl daemon-reload
sudo systemctl enable --now containerd

#---
#
VERSION=1.1.12
wget https://github.com/opencontainers/runc/releases/download/v$VERSION/runc.$PLATFORM
sudo install -m 755 runc.$PLATFORM /usr/local/sbin/runc


#---
VERSION=1.4.1
wget https://github.com/containernetworking/plugins/releases/download/v$VERSION/cni-plugins-linux-$PLATFORM-v$VERSION.tgz
sudo mkdir -p /opt/cni/bin
sudo tar Cxzvf /opt/cni/bin cni-plugins-linux-amd64-v$VERSION.tgz

#-------------------------------------------------------
sudo apt-get update
# apt-transport-https may be a dummy package; if so, you can skip that package
sudo apt-get install -y apt-transport-https ca-certificates curl gpg
#-------------------------------------------------------
# If the directory `/etc/apt/keyrings` does not exist, it should be created before the curl command, read the note below.
# sudo mkdir -p -m 755 /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
#-------------------------------------------------------
# This overwrites any existing configuration in /etc/apt/sources.list.d/kubernetes.list
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
#-------------------------------------------------------
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
#-------------------------------------------------------
sudo systemctl enable --now kubelet


