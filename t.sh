#!/bin/bash

#HN=$1
HN=""

while [ $# -ge 1 ]
do
  case "$1" in
   -h|--help)
      usage
      exit 0
      ;;
   -hn|--hostname)
      shift
      HN=$1
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


getVLANinfo(){
#IPADDR=$(nslookup "$1" | grep -iE "Address: " | awk '{print $2}')
#IP=$(echo $IPADDR | cut -d"." -f1-3)        #get the first 3 octects
IP="10.28.222"
#printf "\nStatic IP for "$1" : $IPADDR \n"

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




getVLANinfo "10.28.222"
