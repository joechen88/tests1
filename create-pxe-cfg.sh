#!/bin/bash

#
#   create-pxe-cfg.sh will generate a pxe-cfg file w/ a timestamp and store it in /vsanhol-nfs-array/vsancert-pxe-cfg location
#
#   Usage: create-pxe-cfg.sh IP-address hostname gateway netmask vmnic nameserver timestamp
#

PROG=`basename $0`

USERNAME=""
IPADDR=""
HN=""
GW=""
NETMASK=""
VMNIC=""
NAMESERVER=""
TIMESTAMP=""

#
#    HASH TABLE -> [  IP-with-only-3-octects : LAB_LOCATION-NETMASK-GW-DNS1,DNS2 ]
#
#        static IP are generally assigned in 10.28.240.x in PROM-E
#        PROME: 10.28.208-223.x are mainly use for VM NETWORK purposes
#               adding it in here as well just in case one day some of the static IP are assigned in that range
#
vlan=( "10.28.240:prome-255.255.255.0-10.28.240.253-10.20.20.1,10.20.20.2" \
       #######################################################################
       "10.28.208:prome-255.255.240.0-10.28.223.253-10.17.131.1,10.17.131.2" \
       "10.28.209:prome-255.255.240.0-10.28.223.253-10.17.131.1,10.17.131.2" \
       "10.28.210:prome-255.255.240.0-10.28.223.253-10.17.131.1,10.17.131.2" \
       "10.28.211:prome-255.255.240.0-10.28.223.253-10.17.131.1,10.17.131.2" \
       "10.28.212:prome-255.255.240.0-10.28.223.253-10.17.131.1,10.17.131.2" \
       "10.28.213:prome-255.255.240.0-10.28.223.253-10.17.131.1,10.17.131.2" \
       "10.28.214:prome-255.255.240.0-10.28.223.253-10.17.131.1,10.17.131.2" \
       "10.28.215:prome-255.255.240.0-10.28.223.253-10.17.131.1,10.17.131.2" \
       "10.28.216:prome-255.255.240.0-10.28.223.253-10.17.131.1,10.17.131.2" \
       "10.28.217:prome-255.255.240.0-10.28.223.253-10.17.131.1,10.17.131.2" \
       "10.28.218:prome-255.255.240.0-10.28.223.253-10.17.131.1,10.17.131.2" \

       "10.28.219:prome-255.255.240.0-10.28.223.253-10.17.131.1,10.17.131.2" \
       "10.28.220:prome-255.255.240.0-10.28.223.253-10.17.131.1,10.17.131.2" \
       "10.28.221:prome-255.255.240.0-10.28.223.253-10.17.131.1,10.17.131.2" \
       "10.28.222:prome-255.255.240.0-10.28.223.253-10.17.131.1,10.17.131.2" \
       "10.28.223:prome-255.255.240.0-10.28.223.253-10.17.131.1,10.17.131.2" \
       ########################################################################
       "10.24.41:promb-255.255.224.0-10.24.63.253-10.17.131.1,10.17.131.2" \
       "10.24.88:promb-255.255.252.0-10.24.91.255-10.17.131.1,10.17.131.2" \
       "10.24.32:promb-255.255.224.0-10.24.63.253-10.17.131.1,10.17.131.2")


usage() {
cat << EOF

   $PROG [flags]

   Flags that take arguments:
   -h|--help:
   -u|--username: ldap username
   -i|--ipaddress: IP
   -hn|--hostname: hostname
   -g|--gateway: gateway
   -n|--netmask: netmask
   -m|--nameserver: DNS IP  [ add a comma between 2 IP for 2 DNS: 1.2.3.4,6.7.8.9.10 ]
   -v|--vmnic: vmnic#
   -t|--timestamp: Timestamp


   Usage:

       $PROG <USERNAME> <ESX_IP> <HOSTNAME> <GATEWAY> <NETMASK> <NAMESERVER> <VMNIC> <TIMESTAMP>

EOF
}

while [ $# -ge 1 ]
do
  case "$1" in
   -h|--help)
      usage
      exit 0
      ;;
   -u|--username)
      shift
      USERNAME=$1
      ;;
   -i|--ipaddress)
      shift
      IPADDR=$1
      ;;
   -hn|--hostname)
      shift
      HN=$1
      ;;
   -g|--gateway)
      shift
      GW=$1
      ;;
   -n|--netmask)
      shift
      NETMASK=$1
      ;;
   -m|--nameserver)
      shift
      NAMESERVER=$1
      ;;
   -v|--vmnic)
      shift
      VMNIC=$1
      ;;
   -t|--timestamp)
      shift
      TIMESTAMP=$1
      ;;
   -*)
      echo "Not implemented: $1" >&2
      exit 1
      ;;
   *)
      break
      exit 0
      ;;
  esac
  shift
done

getVLANinfo(){
IPADDR=$(nslookup $HN | grep -iE "Address: " | awk '{print $2}')
IP=$(echo $IPADDR | cut -d"." -f1-3)        #get the first 3 octects
printf "\nStatic IP for "$1" : $IPADDR \n"

for i in "${vlan[@]}"
do
     key="${i##*:}"
     value="${i%%:*}"
     if [ $IP == $value ];then

          NETMASK=$(echo $key | awk -F"-" '{ print $2 }')
          printf "Netmask: $NETMASK \n"
          GW=$(echo $key | awk -F"-" '{ print $3 }')
          printf "Gateway: $GW \n"
          NAMESERVER=$(echo $key | awk -F"-" '{ print $4 }')
          printf "DNS: $NAMESERVER \n"
     fi
done
}


# -z verifies if IPADDR, NETMASK, GW, and NAMESERVER are empty
if [[ -z "$IPADDR" && -z "$NETMASK" && -z "$GW" && -z "$NAMESERVER" ]]; then
    printf "\nGet network info for $HN"
    getVLANinfo "$HN"
fi


# creates pxe-cfg file on-the-fly 
cat >> /vsanhol-nfs-array/vsancert-pxe-cfg/pxe-cfg-${USERNAME}-${TIMESTAMP} << EOF
#Accept the VMware End User License Agreement
vmaccepteula
# Set the root password for the DCUI and Tech Support Mode
rootpw ca\$hc0w
# Choose the first discovered disk to install onto
install --firstdisk=usb,esx,local,remote --ignoressd --overwritevmfs --novmfsondisk
#--overwritevmfs --novmfsondisk
#--preservevmfs
# Set the network to DHCP on the first network adapater
network --bootproto=static --ip=${IPADDR} --gateway=${GW} --netmask=${NETMASK} --hostname=${HN} --device=${VMNIC} --addvmportgroup=1 --nameserver=${NAMESERVER}
%post --interpreter=python --ignorefailure=true
import time
import os
stampFile = open('/finished.stamp', mode='w')
stampFile.write( time.asctime() )
os.system("localcli network firewall set -e false")
EOF

printf "\nkickstart file created in /vsanhol-nfs-array/vsancert-pxe-cfg/pxe-cfg-${USERNAME}-${TIMESTAMP} \n\n"
