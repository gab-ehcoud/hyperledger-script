#!/bin/bash
function select_option {
    ESC=$( printf "\033")
    cursor_blink_on()  { printf "$ESC[?25h"; }
    cursor_blink_off() { printf "$ESC[?25l"; }
    cursor_to()        { printf "$ESC[$1;${2:-1}H"; }
    print_option()     { printf "   $1 "; }
    print_selected()   { printf "  $ESC[7m $1 $ESC[27m"; }
    get_cursor_row()   { IFS=';' read -sdR -p $'\E[6n' ROW COL; echo ${ROW#*[}; }
    key_input()        { read -s -n3 key 2>/dev/null >&2
                         if [[ $key = $ESC[A ]]; then echo up;    fi
                         if [[ $key = $ESC[B ]]; then echo down;  fi
                         if [[ $key = ""     ]]; then echo enter; fi; }
    for opt; do printf "\n"; done

    local lastrow=`get_cursor_row`
    local startrow=$(($lastrow - $#))
    trap "cursor_blink_on; stty echo; printf '\n'; exit" 2
    cursor_blink_off

    local selected=0
    while true; do
        local idx=0
        for opt; do
            cursor_to $(($startrow + $idx))
            if [ $idx -eq $selected ]; then
                print_selected "$opt"
            else
                print_option "$opt"
            fi
            ((idx++))
        done

        case `key_input` in
            enter) break;;
            up)    ((selected--));
                   if [ $selected -lt 0 ]; then selected=$(($# - 1)); fi;;
            down)  ((selected++));
                   if [ $selected -ge $# ]; then selected=0; fi;;
        esac
    done

    cursor_to $lastrow
    printf "\n"
    cursor_blink_on

    return $selected
}

if [ "$EUID" -ne 0 ]
  then echo -e "\e[1;31mPlease run as root"
  exit
fi
sudo -i
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
        echo -e "\e[1;37mMaking Sure Docker daemon is running."
        sudo systemctl start docker
        sudo systemctl enable docker
        mkdir Fabric-Samples
        cd Fabric-Samples
        echo -e "\n"
        echo "Downloading Fabric samples, Docker images, and binaries"
        curl -sSL https://bit.ly/2ysbOFE | bash -s        
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
        # read CHANNELNAME1
        ./network.sh createChannel
        # echo -e "Input second channel name"
        # read CHANNELNAME2
        # ./network.sh createChannel -c $CHANNELNAME2
        echo -e "Please Select the language:"
        echo

        options=("java" "Node/JS" "GO")

        select_option "${options[@]}"
        choice=$?

        if [[ $choice == "0" ]]; then
                ./network.sh deployCC -ccn basic -ccp ../asset-transfer-basic/chaincode-java -ccl java -c $CHANNELNAME1
                ./network.sh deployCC -ccn basic -ccp ../asset-transfer-basic/chaincode-java -ccl java -c $CHANNELNAME2
        elif [[ $choice == "1" ]]; then
                ./network.sh deployCC -ccn basic -ccp ../asset-transfer-basic/chaincode-javascript -ccl javascript
        elif [[ $choice == "2" ]]; then
                ./network.sh deployCC -ccn basic -ccp ../asset-transfer-basic/chaincode-go -ccl go -c $CHANNELNAME1
                ./network.sh deployCC -ccn basic -ccp ../asset-transfer-basic/chaincode-go -ccl go -c $CHANNELNAME2
        fi
        echo
        echo "ADDING BINARIES TO PATH"
        export PATH=${PWD}/../bin:$PATH
        echo
        echo "SETTING FABRIC_CFG_PATH"
        export FABRIC_CFG_PATH=$PWD/../config/
        echo
        echo "SETTING ENVIRONMENT VARIABLES"
        export CORE_PEER_TLS_ENABLED=true
        export CORE_PEER_LOCALMSPID="Org1MSP"
        export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
        export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
        export CORE_PEER_ADDRESS=localhost:7051
        echo
        echo 
        echo -e "\e[1;34mInitializing the ledger with assets"
        peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem" -C mychannel -n basic --peerAddresses localhost:7051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt" --peerAddresses localhost:9051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt" -c '{"function":"InitLedger","Args":[]}'

        echo -e "\e[1;33mGetting arguments to verify the installation"
        
        peer chaincode query -C mychannel -n basic -c '{"Args":["GetAllAssets"]}' 
else
        echo "We don't do that here"
fi
