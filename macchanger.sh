#!/bin/bash

net_int=${1:-eno1}


sleep 0.5
echo -e "\n----------------MAC-changer--------------\n"
sleep 0.5
echo "Network interface - $1"
echo -e "Checking the Linux OS..."
linuxv=$(hostnamectl | grep System | awk -F' ' '{print $3}')
if [[ "$linuxv" == 'Pop!_OS' ]]; then
	echo -e "You system is $linuxv so trying the apt commands...."
fi	

echo -e "\nChecking macchange is installed or not ...."
sleep 0.5

result=$(apt list --installed | grep macchanger | wc -l)

if [[ "$result" == 1 ]]; then
	echo -e "Machanger is installed already . . "
	sleep 0.5

else
	echo -e "Script need mcchanger so downloading the package"
	sleep 0.3
	echo "sudo apt install macchanger"
	sudo apt install macchanger -y
	sleep 0.5
fi

echo -e "getting the list of the vendors and create a file"

macchanger -l >list.txt
echo -e "list Generated .."
sleep 0.5
echo -e "File - list.txt"

sleep 0.5
echo -e "Selecting the one vendor"
vendor=$(cat list.txt | shuf -n 1 | awk -F' ' '{print $3}')
echo -e "Vendor prifix - $vendor" 
name=$(cat list.txt | grep $vendor | awk -F' ' '{print $5}')
echo -e "Vendor Name is - $name"
sleep 0.5


echo -e "Generating the random hexadecimal values..."
sleep 0.5
random1=$[RANDOM%255]
random2=$[RANDOM%255]
random3=$[RANDOM%255]

rd=$(printf "%02x:%02x:%02x" $random1 $random2 $random3)


echo -e "Your New Mac address will be $vendor:$rd"

macchanger -m "$vendor:$rd" $net_int


echo "Your Mac Adress of network interface $net_int is Succesfully Changed with origin Vendors list..."

sleep 0.2
