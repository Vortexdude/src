#!/bin/bash

#all the roles are here
roles="${@:-test_role}"


#creating the ansible directory, playbook, ansible.cfg, and inventory
mkdir -p ansible{/inventory,/roles}  && cd ansible

#creating playbook, configuration and inventory files
files="main.yml ansible.cfg inventory/all"
for file in $files; do touch $file; done

cat <<EOF >> ansible.cfg  
[defaults]
callback_whitelist = profile_tasks
inventory = inventory/all
stdout_callback = yaml

EOF

#Getting all the roles
for role in $roles; do

# list of directories
  dirs="defaults tasks templates handlers library"

#craeting the directories and files
  for dir in $dirs; do
    mkdir -p "roles/$role/$dir"
    
    #creating template file
    if [[ "$dir" == 'templates' ]]; then touch "roles/$role/$dir/server.conf.j2" && continue; fi
    
    #creating module file
    if [[ "$dir" == 'library' ]]; then wget https://raw.githubusercontent.com/Vortexdude/src/main/hello.py -O roles/$role/$dir/hello.py && continue; fi
    
    #creating taks file
    if [[ "$dir" = 'tasks' ]]; then
cat <<EOF  >> "roles/$role/$dir/main.yml"
- name: New hello module
  hello:
    name: 'hello'
    new: true
  register: testout
- name: output of the hello command
  debug:
    msg: '{{ testout }}'
  
EOF
continue
fi
    
    #create rest of the file
    touch "roles/$role/$dir/main.yml"
  done
  echo "Your role is $role is created Succesfully "
done

#Creating playbook
cat <<EOF  >> main.yml
- hosts: localhost
  become: true
  roles:
  
EOF
# include role in the playbook
for role in $roles; do
cat << EOF >>main.yml
    - { role: $role }
EOF
done
