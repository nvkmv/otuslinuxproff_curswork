#! /bin/bash
# create vps in digital ocean#
cd terraform
terraform apply -auto-approve && terraform show | grep "ipv4_address " > addres
ip=$(cat addres| awk '{print $3}' | cut -d '"' -f 2)
echo "$ip ansible_user=root" >> ../ansible/hosts
cd ..
# send to prometheus ip adress from vps 
sed  -i "39a \      - targets: [\"$ip:9113\"]" monitoring/prometheus.yml #жесткий, галимый костыль

echo "      - targets: [\"$ip:9100\"]" >> monitoring/prometheus.yml
# genrate keys for wireguarg server and add to ansible vars file
mkdir server_keys
wg genkey | tee server_keys/server.privatekey | wg pubkey > server_keys/server.pubkey
server_privkey=$(cat server_keys/server.privatekey)
server_pubkey=$(cat server_keys/server.pubkey)
echo "server : $server_privkey" > ansible/group_vars/all.yml
# generate wireguard keys for firs client
mkdir first_client
wg genkey | tee first_client/first_client.privatekey | wg pubkey > first_client/first_client.pubkey
first_client_pubkey=$(cat first_client/first_client.pubkey)
first_client_privatekey=$(cat first_client/first_client.privatekey)
echo "first_client_pubkey : $first_client_pubkey" >> ansible/group_vars/all.yml
cat << EOF > first_client/wg0.conf
[Interface]#first_client
PrivateKey = $first_client_privatekey
Address = 10.0.0.2

[Peer]
PublicKey = $server_pubkey
Endpoint = $ip:51520
AllowedIPs = 0.0.0.0/0
PersistentKeepalive = 25

EOF

cp first_client/wg0.conf ansible/roles/wg_vpn-first/templates
# generate wireguard keys and config for second client
mkdir second_client
wg genkey | tee second_client/second_client.privatekey | wg pubkey > second_client/second_client.pubkey
second_client_pubkey=$(cat second_client/second_client.pubkey)
second_client_privatekey=$(cat second_client/second_client.privatekey)
echo "second_client_pubkey : $second_client_pubkey" >> ansible/group_vars/all.yml
cat << EOF > second_client/wg0.conf
[Interface]#second_client
PrivateKey = $second_client_privatekey
Address = 10.0.0.3

[Peer]
PublicKey = $server_pubkey
Endpoint = $ip:51520
AllowedIPs = 0.0.0.0/0
PersistentKeepalive = 25

EOF

cp second_client/wg0.conf ansible/roles/wg_vpn_app2/templates/
#


# up vagrant machines

vagrant up

sleep 30
cd ansible
ansible-playbook config_server.yml 