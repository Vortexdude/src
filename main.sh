#!/bin/bash
set -x


clone_path="/tmp/.srelia/cloned_repo"
clone_url="https://github.com/Vortexdude/src"
branch_name="547-testing-ansible-pull"

function usage(){
echo "Please use as $0 user1 user2 user3 ..."
}

# exit from usages
if [[ "${#}" -lt 1 ]]; then usage && exit 1; fi

#get the os version
os_version=$(cat /etc/os-release | grep PRETTY_NAME | awk -F= '{print $2}' | tr -d '"' | awk '{print $1}')

# installing ansible 
echo "**** Installing ansible"
if [[ "${os_version}" -eq "Ubuntu" ]]; then apt install ansible jq -y 2>error.log >/dev/null; else yum install ansible jq -y 2>error.log >/dev/null; fi

umask 77 && mkdir -p ${clone_path}
echo "**** Cloning the repo ${clone_url} in the branch ${branch_name}"
git clone -b ${branch_name} ${clone_url} "${clone_path}" &>/dev/null
# Creating var file
echo "users: " >${clone_path}/vars.yml
for name in "${@}"
do
cat << EOF >> ${clone_path}/vars.yml
  - { name: ${name}, password: ${name}, admin: true}
EOF
done

# run the ansible playbook
server=localhost
connection=local
echo "**** Running Ansible playbook"
echo $(ansible-playbook ${clone_path}/local.yml -i ${server}, -c ${connection} -e "@${clone_path}/vars.yml")
echo "**** Deleting temprary files"
#rm -rf ${clone_path}
if [[ "${?}" -eq 0 ]]; then echo "**** Succesfully created ${#} users - ${@}" ; else "****  There might be an issue" && exit 1; fi
