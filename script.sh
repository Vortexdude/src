#!/bin/bash
roles="${@:-test_role}"

#creating the ansible directory, playbook, ansible.cfg, and inventory

mkdir -p ansible/inventory && cd ansible && mkdir roles

files="main.yml ansible.cfg inventory/all"
for file in $files; do
touch $file
done

cat <<EOF >> ansible.cfg
[defaults]
callback_whitelist = profile_tasks
inventory = inventory/all

EOF

for role in $roles; do

# list of directories
dirs="defaults tasks templates handlers"

#craeting the directories and files
for dir in $dirs; do
mkdir -p "roles/$role/$dir"
if [[ "$dir" == 'templates' ]]; then
touch "roles/$role/$dir/main.yml.j2"
continue
fi
touch "roles/$role/$dir/main.yml"
done
echo "Your role is $role is created Succesfully "
done
cat <<EOF  >> main.yml
- hosts: localhost
  become: true
  roles:
EOF

for role in $roles; do
cat << EOF >>main.yml
    - { role: $role }
EOF
done
