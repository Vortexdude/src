#!/bin/bash
roles="${@:-test_role}"


#creating the ansible directory, playbook, ansible.cfg, and inventory
mkdir -p ansible{/inventory,/roles}  && cd ansible

files="main.yml ansible.cfg inventory/all"
for file in $files; do touch $file; done

cat <<EOF >> ansible.cfg  
[defaults]
callback_whitelist = profile_tasks
inventory = inventory/all

EOF

for role in $roles; do

# list of directories
  dirs="defaults tasks templates handlers library"

#craeting the directories and files
  for dir in $dirs; do
    mkdir -p "roles/$role/$dir"
    if [[ "$dir" == 'templates' ]]; then touch "roles/$role/$dir/server.conf.j2" && continue; fi
    if [[ "$dir" == 'library' ]]; then wget https://raw.githubusercontent.com/Vortexdude/src/main/hello.py -O roles/$role/$dir/hello.py && continue; fi
    if [[ "$dir" = 'tasks' ]];
cat <<EOF  >> roles/$role/$dir/main.yml
- name: run the new module
  hello:
    name: 'hello'
    new: true
  register: testout
- name: dump test output
  debug:
    msg: '{{ testout }}'
  
EOF
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
