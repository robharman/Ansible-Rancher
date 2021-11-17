mkdir -p /usr/local/share/aptgpgkeys/
mkdir /tmp/kubeinstall
cd /tmp/kubeinstall

wget https://packages.cloud.google.com/apt/doc/apt-key.gpg
gpg --no-default-keyring --keyring /tmp/kubeinstall/apt-key.gpg --export --output /usr/local/share/aptgpgkeys/kubernetes.gpg
rm ./apt-key.gpg

echo 'deb [signed-by=/usr/local/share/aptgpgkeys/kubernetes.gpg] https://apt.kubernetes.io/ kubernetes-xenial main' > /etc/apt/sources.list.d/kubernetes.list

apt update
apt install -y kubelet kubeadm kubectl
