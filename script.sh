#!/bin/bash
role="${1:-test_role}"

#creating the ansible directory, playbook, ansible.cfg, and inventory

mkdir -p ansible/inventory && cd ansible

files="main.yml ansible.cfg inventory/all"
for file in $files; do
touch $file
done

cat <<EOF >> ansible.cfg
[defaults]
callback_whitelist = profile_tasks
inventory = inventory/all

EOF

# list of directories
dirs="defaults tasks templates handlers"

#craeting the directories and files
for dir in $dirs; do
mkdir -p "$role/$dir"
if [[ "$dir" == 'templates' ]]; then
touch "$role/$dir/main.yml.j2"
continue
fi
touch "$role/$dir/main.yml"
done

cat <<EOF  >> main.yml
- host: localhost
  become: true
  roles:
    - { role: $role }

EOF

echo "Your role is $role is created Succesfully "
