#!/bin/bash
roles="${@:-test_role}"


#creating the ansible directory, playbook, ansible.cfg, and inventory
mkdir -p ansible{/inventory,/roles}  && cd ansible
wget https://gist.githubusercontent.com/Vortexdude/09292a3cd3690b0ee27828108d05b842/raw/ff462c88b1d6793b7149996314ad1923bc77cec4/hello.py
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
    #if [[ "$dir" == 'library' ]]; then mv hello.py roles/$role/$dir/ && continue; fi
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

cat <<EOF  >> main.yml
  tasks:
  - name: run the new module
    hello:
      name: 'hello'
      new: true
    register: testout
  - name: dump test output
    debug:
      msg: '{{ testout }}'
EOF
