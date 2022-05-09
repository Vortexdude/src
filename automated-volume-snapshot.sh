#!/bin/bash

set -e

################################################################################
# File:    automated-volume-snapshot.sh
# Purpose: This Script will create volume snapshot of Volume .
# Version: 0.1
# Author:  Nitin Namdev
# Created: 2022-04-04
# Usage: TODO
################################################################################

# Color variables
red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
blue='\033[0;34m'
magenta='\033[0;35m'
cyan='\033[0;36m'
# Clear the color after that
clear='\033[0m'

# Give the first backup rotaaion days default is 5
SNAPSHOT_ROTAION_DAYS=${1:-5}
CURRENT_TIME=$(date +'%Y-%m-%d')
NUMBER_OF_INSTANCE=$(ibmcloud is instances --output json | jq -r '.[] | select(.status=="running") | .id' | wc -l)
echo -e "CURRENT_TIME - ${blue}$CURRENT_TIME${clear}"
echo -e "SNAPSHOT_ROTAION_DAYS - ${blue}$SNAPSHOT_ROTAION_DAYS ${clear}"

#fetch the all instance ids which are running
instances_list(){
    ids=$(ibmcloud is instances --output json | jq -r '.[] | select(.status=="running") | .id')
    # ids="02c7_ec619890-6c87-448c-98e7-970400602767 02c7_0e1e0ca1-da73-425a-a514-049be47c66a5"
    # ids="02c7_7be74789-6d53-4d77-8e49-44c16f4337c4"
    echo $ids
}

#create a snapshot
create_snapshot(){
    instance_id=$1
    boot_volume_id=$2
    instance_name=$(get_instance_detail ${instance_id} name)
    resource_group_id=$(get_instance_detail ${instance_id} resource_group.id)
    instance_name=$(echo $instance_name | tr '_' '-')
    echo -e "instance_name - ${cyan}$instance_name${clear}"
    echo -e "resource_group_id - ${cyan}$resource_group_id${clear}"
    volume_id=$boot_volume_id
    echo -e "volume_id - ${cyan}$volume_id${clear}"
    snapshot_name="${instance_name}-"`date +"%d-%m-%Y-%H-%M"`
    echo -e "snapshot_name - ${cyan}${snapshot_name}${clear}"
    snapshot_id=$(ibmcloud is snapshot-create --name $snapshot_name --volume $volume_id --resource-group-id $resource_group_id --output json | jq -r .id )
    echo -e "snapshot_id - ${cyan}${snapshot_id}${clear}"
    snapshot_ready ${snapshot_id}
}

#for waiting when the snpashot is ready
snapshot_ready() {
    snapshot_id=$1  
    state=$(ibmcloud is snapshot $snapshot_id --output json | jq -r .lifecycle_state)
    while true ; do
        if [[ "${state}" == "stable" ]]; then
            echo -e "Snapshot is ${green}Stable${clear} state"
            snapshot_size=$(get_snapshot_datails $snapshot_id size)
            echo -e "snapshot_size - ${cyan}${snapshot_size}GB${clear}\n"
            break
        elif [[ "${state}" == "failed" ]]; then
            echo -e "${red}Error to create snapshot please check the instance state and volume state${clear}"
            break
        fi
        echo -e "Snapshot state is ${yellow}${state}${clear} ..."
        sleep 30
        state=$(ibmcloud is snapshot $snapshot_id --output json | jq -r .lifecycle_state)
    done
}

#fetch all the list of snapshot ids
snapshot_list(){
    volume_id=$1
    ids=$(ibmcloud is snapshots --volume $volume_id --output json | jq -r .[].id)
    echo $ids
}

#give the second arguement for fetch the other detail the created_at is set to default
get_snapshot_datails(){
    id=$1
    param=${2:-created_at}
    value=$(ibmcloud is snapshot $id --output json | jq -r .$param )
    echo $value
}

#give the second arguement for fetch the other detail the boot_volume_id  is set to default
get_instance_detail(){
    id=$1
    param=${2:-boot_volume_attachment.volume.id}
    value=$(ibmcloud is instance $instance_id --output json | jq -r .$param )
    echo $value
}

#for deleting the snapshot give the snapshot id
delete_snapshot(){
    snapshot_id=$1
    state=$(get_snapshot_datails ${snapshot_id} lifecycle_state)
    if [[ "${state}" == "deleting" ]]
    then
        echo -e "${red}\n This Snapshot is in unstable state \n${clear}"
    else
    echo -e "${red}Deleting Snapshot $snapshot_id ${clear}\n"
    ibmcloud is snapshot-delete $snapshot_id -f
    fi
}

rotate_snapshot(){
    volume_id=$1
    snapshot_ids=$(snapshot_list ${volume_id} )
    for snapshot_id in ${snapshot_ids}; do
        created_time=$(get_snapshot_datails ${snapshot_id})
        snapshot_name=$(get_snapshot_datails ${snapshot_id} name)
        sdate=$(date --date="$CURRENT_TIME" '+%s')
        edate=$(date --date="$created_time" '+%s')
        days=$(( (sdate - edate) / 86400 ))
        echo -e "\n${yellow}$snapshot_name${clear} snapshot is taken ${yellow}$days${clear} days ago.\n"
        if [[ $days -gt $SNAPSHOT_ROTAION_DAYS ]]
        then
            res=$(delete_snapshot ${snapshot_id})
            echo $res
        fi
    done 
}

INDEX=0
instance_ids=$(instances_list)
for instance_id in ${instance_ids}; do
     boot_volume_id=$(get_instance_detail ${instance_id})
     instance_name=$(get_instance_detail ${instance_id} name)
     echo -e "\n${INDEX}/${NUMBER_OF_INSTANCE} -------------------- For ${green}${instance_name}${clear} Instance --------------------"
     if [[ -z $(snapshot_list ${boot_volume_id}) ]]
     then
        echo -e "\nNo existing snapshots were Found in ${yellow}$instance_name${clear} instance"
        echo -e "\n${green}************** Creating Snapshot ********************\n${clear}"
        create_snapshot ${instance_id} ${boot_volume_id}
        echo -e "${green}************** Snapshot is ready ********************${clear}\n"
     else
        echo -e "\n${green}************** Creating Snapshot ********************\n${clear}"
        create_snapshot ${instance_id} ${boot_volume_id}
        echo -e "${green}************** Snapshot is ready ********************${clear}\n"
        if [[ "${state}" == "stable" ]]
        then
            rotate_snapshot ${boot_volume_id}
        fi 
     fi
     INDEX=$(( INDEX + 1 ))
done 
