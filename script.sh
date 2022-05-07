#!/bin/bash
role="${1:-test_role}"

echo $role
mkdir -p ansible && cd ansible && touch main.yml

dirs="defaults tasks templates handlers"

#craeting the directories
for dir in $dirs; do
mkdir -p "$role/$dir"
if [[ "$dir" == 'templates' ]]; then
touch "$role/$dir/main.yml.j2"
continue
fi
touch "$role/$dir/main.yml"
done

cat <<EOF  >> ../ansible/main.yml
- host: localhost
  become: true
  roles:
    - { role: $role }

EOF