# installing ansible 

os_version=$(cat /etc/os-release | grep PRETTY_NAME | awk -F= '{print $2}' | tr -d '"' | awk '{print $1}')

if [[ "${os_version}" -eq "Ubuntu" ]]; then apt install ansible -y 2>error.log >/dev/null; else yum install ansible -y 2>error.log >/dev/null; fi

# creating direcotries
mkdir -p ansible
> ansible/main.yml

# Creating files content
cat << EOF > ansible/main.yml
---
- hosts: all
  become: yes
  vars:
    users:
      - { name: indagent, passsword: indagent, admin: true }
      - { name: ukagent, passsword: ukagent, admin: false }
  tasks:
    - user: name="{{ item.name }}" password="{{ item.passsword | password_hash('sha512') }}"
      with_items: "{{ users }}"
    - shell: adduser {{ item.name }} root && adduser {{ item.name }} sudo
      with_items: "{{ users }}"
      when: item.admin | bool 
    - stat: path=/etc/ssh/sshd_config.d/50-cloudimg-settings.conf
      register: statofshh
    - lineinfile: line='PasswordAuthentication yes' regex='^PasswordAuthentication' path='/etc/ssh/sshd_config.d/50-cloud-init.conf'
      when: statofshh.stat.exists
      register: sshconfig
    - service: name=sshd state=restarted
      when: sshconfig.changed

EOF

# run the ansible playbook
ansible-playbook ansible/main.yml -i localhost, -c local

if [[ "${?}" -eq 0 ]]; then rm -rf ansible/* ; fi
