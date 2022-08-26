#!/bin/bash
if [ "$EUID" -ne 0 ]
  then echo -e "\e[1;31mPlease run as root"
  exit
fi
echo -e "\n"
echo -e "\e[1;34m-----Hyperledger Fabric-----"
echo -e "\e[33mRather than an open permissionless system that allows unknown identities to participate in the network (requiring protocols like “proof of work” to validate transactions and secure the network), the members of a Hyperledger Fabric network enroll through a trusted Membership Service Provider (MSP)."
echo -e "\n"
echo -e "\e[1;35mAnalyzing the System"
sleep 2
echo "Install Tools? [Y,N]"
read input
if [[ $input == "Y" || $input == "y" ]]; then
        echo -e "\e[1;33mSit Relax and Grab a Chai!!"
        sudo apt-get install git curl docker-compose -qq
        echo -e "\n"
        echo -e "\e[1;34mDocker is ready"
        docker --version | awk -F, '{ print $1 }' 
        docker-compose --version | awk -F, '{ print $1 }'

        
else
        echo "We don't do that here"
fi
