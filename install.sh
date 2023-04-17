#!/bin/bash

# Input params
# $1 -> TUNNEL1_VGW_OUTSIDE_IP
# $2 -> TUNNEL2_VGW_OUTSIDE_IP
# $3 -> TUNNEL1_CGW_INSIDE_IP
# $4 -> TUNNEL1_VGW_INSIDE_IP
# $5 -> TUNNEL2_CGW_INSIDE_IP
# $6 -> TUNNEL2_VGW_INSIDE_IP
# $7 -> CGW_ASN
# $8 -> AWS_ASN
# $9 -> ONPREM_CIDR
# $10 -> TUNNEL1_PSK
# $11 -> TUNNEL2_PSK
# $12 -> GITREPO (GoozeyX/ipsecbootstrap/main)

# Step 1: Download all the needed configuration files
wget https://raw.githubusercontent.com/$12/bgpd.conf -P /root/
wget https://raw.githubusercontent.com/$12/ipsec-vti.sh -P /root/
wget https://raw.githubusercontent.com/$12/ipsec.conf -P /root/
wget https://raw.githubusercontent.com/$12/ipsec.secrets -P /root/
wget https://raw.githubusercontent.com/$12/strongswan.conf -P /root/
wget https://raw.githubusercontent.com/$12/sysctl.conf -P /root/
wget https://raw.githubusercontent.com/$12/zebra.conf -P /root/

# Replace needed data in ipsec.conf with SED and then move it to the right folder and chmod/chown it
sed -i 's/TUNNEL1_VGW_OUTSIDE_IP/'$1'/g' /root/ipsec.conf
sed -i 's/TUNNEL2_VGW_OUTSIDE_IP/'$2'/g' /root/ipsec.conf

# Replace needed data in ipsec-vti.sh and move it to the right folder and chmod/chown it
sed -i 's/TUNNEL1_CGW_INSIDE_IP/'$3'/g' /root/ipsec-vti.sh
sed -i 's/TUNNEL1_VGW_INSIDE_IP/'$4'/g' /root/ipsec-vti.sh
sed -i 's/TUNNEL2_CGW_INSIDE_IP/'$5'/g' /root/ipsec-vti.sh
sed -i 's/TUNNEL2_VGW_INSIDE_IP/'$6'/g' /root/ipsec-vti.sh

# Replace needed data in Zebra.conf and BGPD.conf (PRIVATE_IP and HOSTNAME)
ipaddr=$(curl 169.254.169.254/latest/meta-data/local-ipv4)
sed -i -e "s/PRIVATE_IP/$ipaddr/" /root/zebra.conf 
sed -i -e "s/PRIVATE_IP/$ipaddr/" /root/bgpd.conf 
hostname=$(curl 169.254.169.254/latest/meta-data/local-hostname)
sed -i -e "s/HOSTNAME/$hostname/" /root/zebra.conf

# Replace needed data in bgpd.conf
sed -i 's/CGW_ASN/'$7'/g' /root/bgpd.conf
sed -i 's/AWS_ASN/'$8'/g' /root/bgpd.conf
sed -i 's/ONPREM_CIDR/'$9'/g' /root/bgpd.conf
sed -i 's/TUNNEL1_VGW_INSIDE_IP/'$4'/g' /root/bgpd.conf
sed -i 's/TUNNEL2_VGW_INSIDE_IP/'$6'/g' /root/bgpd.conf

# Replace needed data inside ipsec.secrets
sed -i 's/TUNNEL1_PSK/'$10'/g' /root/ipsec.secrets
sed -i 's/TUNNEL2_PSK/'$11'/g' /root/ipsec.secrets