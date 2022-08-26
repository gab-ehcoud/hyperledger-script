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
        echo -e "\n"
        echo -e "\e[1;47mMaking Sure Docker daemon is running."
        sudo systemctl start docker
        mkdir Fabric-Samples
        cd Fabric-Samples
        echo -e "\n"
        echo "Downloading Fabric samples, Docker images, and binaries"
        curl -sSLO https://raw.githubusercontent.com/hyperledger/fabric/main/scripts/install-fabric.sh && chmod +x install-fabric.sh
        ./install-fabric.sh docker binary samples
        cd fabric-samples/test-network
        ./network.sh down
        docker rm -f $(docker ps -aq)
        echo -e "\n"
        echo -e "\e[1;33mBRINGING UP THE NETWORK"
        echo -e "\n"
        ./network.sh up
        echo -e "\n"
        echo -e "\e[1;33mCREATING CHANNEL"
        echo -e "Input first channel name"
        read CHANNELNAME1
        ./network.sh createChannel -c $CHANNELNAME1
        echo -e "Input second channel name"
        read CHANNELNAME2
        ./network.sh createChannel -c $CHANNELNAME2
else
        echo "We don't do that here"
fi
