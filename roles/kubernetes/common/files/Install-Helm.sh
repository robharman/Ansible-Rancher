mkdir -p /usr/local/share/aptgpgkeys/
mkdir /tmp/helm
cd /tmp/helm

wget https://baltocdn.com/helm/signing.asc
gpg --no-default-keyring --keyring ./temp-keyring.gpg --import ./signing.asc
gpg --no-default-keyring --keyring ./temp-keyring.gpg --export --output /usr/local/share/aptgpgkeys/helm.gpg
echo /dev/null > ./temp-keyring.gpg
rm ./temp-keyring.gpg -f

echo "deb [signed-by=/usr/local/share/aptgpgkeys/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" > /etc/apt/sources.list.d/helm.list
apt update

apt install helm