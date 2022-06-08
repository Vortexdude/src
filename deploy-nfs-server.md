
# Deploy NFS Cluster using Gitlab CI/CD, Terraform and Ansible 

The Deployment of the NFS servers done by the terraform and the server configuration we used ansible.
</br>
In the terraform/templates/nfs-cluster we used terraform.tfvars file to launch and manage the servers
</br>
The tfvar file is given here

``` terraform
NFS_MASTER_INSTANCE_NAME = "ipt-fr-nfs-cluster-master-tf"
NFS_MASTER_VOLUME_NAME = "ipt-fr-nfs-cluster-master-vol-tf"
NFS_MASTER_BOOT_VOLUME_NAME = "ipt-fr-nfs-cluster-master-boot-vol-tf"
NFS_MASTER_NODE_TAGS = ["nfs", "cluster", "terraform", "master"]
NFS_MASTER_ZONE = "eu-de-1"
NFS_MASTER_SUBNET_ID = "02b7-b3693351-6882-4218-8e92-d1a112180a21"
IMAGE_ID = "r010-067bd38b-7ddd-49d9-a7f3-6e0a798e0554"
VPC_ID = "r010-5ba844f2-e74d-4973-9758-198a56647391"
SECURITY_GROUPS = ["r010-5365bfbb-fab4-439b-bfe1-59b19464cf5f", "r010-94c1e834-b639-46a0-85f6-1475c308d511"]
RESOURCE_GROUP = "527c95199ff0484cbf9fed788e155bf1"
TAGS = ["nfs", "cluster", "terraform"]
SSH_KEYS = ["r010-3d6b46df-bc38-472a-bb4e-7354da0fcde5", "r010-16fd2c64-d972-43e8-8588-80a587b0f71e", "r010-62837103-a38c-47bc-b8ec-97ee6bd1991a", "r010-419abec7-3a4a-465b-af7d-114946be033d"]
VOLUME_SIZE = 500
MAX_IOPS = 3000
INSTANCE_PROFILE = "bx2-2x8"
NFS_NODES_DETAILS = [ 
    {
      "NAME" = "ipt-fr-nfs-cluster-eu-de-2-tf"
      "VOLUME_NAME" = "ipt-fr-nfs-cluster-eu-de-2-vol-tf"
      "SUBNET_ID" = "02c7-fc1b8c8d-d8cd-4311-ba57-e45f8375453c"
      "ZONE" = "eu-de-2"
      "BOOT_VOLUME_NAME" = "ipt-fr-instance-eu-de-2-tf-boot-vol"
    },
    {
      "NAME" = "ipt-fr-nfs-cluster-eu-de-3-tf"
      "VOLUME_NAME" = "ipt-fr-nfs-cluster-eu-de-3-vol-tf"
      "SUBNET_ID" = "02d7-82fbb353-c1b4-4559-ba83-31fedd6654bc"
      "ZONE" = "eu-de-3"
      "BOOT_VOLUME_NAME" = "ipt-fr-instance-eu-de-3-tf-boot-vol"
    }   
  ]
APPEND_NODE_TO_CLUSTER = false
```

In the var file the variable **NFS_NODES_DETAILS** hold the all cluster node details like count of the server, name, zone, subnet id and volume name </br>

### Append a new node

If you want to add a new server in the cluster you have to change the variable **APPEND_NODE_TO_CLUSTER** to **true** and give the new node details in the **NFS_NODES_DETAILS** list

## Warning
You have to create a new entry after previously launched server.

## Mount the nfs
In the GitLab CI/CD pipeline in the output of terraform, there is a command of mount the nfs or 
``` bash
mount -t nfs <MASTER Node IP>:/gv0 /mnt

```
