# installing ansible 

function usage(){
echo "Please use as $0 user1 user2 user3 ..."
}


if [[ "${#}" -lt 1 ]]; then usage && exit 1; fi

os_version=$(cat /etc/os-release | grep PRETTY_NAME | awk -F= '{print $2}' | tr -d '"' | awk '{print $1}')

if [[ "${os_version}" -eq "Ubuntu" ]]; then apt install ansible jq -y 2>error.log >/dev/null; else yum install ansible jq -y 2>error.log >/dev/null; fi

# Creating var file
echo "users: " >/tmp/.srelia.log
for name in "${@}"
do
cat << EOF >> /tmp/.srelia.log
  - { username: ${name}, pasword: ${name}, admin: true}
EOF
done

# run the ansible playbook
server=localhost
connection=local
ansible-pull -U https://github.com/Vortexdude/src/tree/547-testing-ansible-pull -i ${server}, -c ${connection} -e "@/tmp/.srelia.log"

if [[ "${?}" -eq 0 ]]; then echo "**** Succesfully created ${#} users - ${@}" ; else "****  There might be an issue with the var file"; fi
