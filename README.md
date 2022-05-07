# Ansible role generator with files in the default manner
```mermaid
  graph TD;
      ansible-->role;
      ansible-->main.yaml
      role-->defaults;
      role-->tasks;
      role-->templates;
      role-->handlers;
      defaults-->main.yml;
      tasks-->main.yml;
      templates-->main.yml.j2;
      handlers-->main.yml;
```



### Run this script via the following command

``` bash
wget -O - https://raw.githubusercontent.com/vortexdude/src/main/script.sh | bash

```

#### Give the name of the role

``` bash
wget -O - https://raw.githubusercontent.com/vortexdude/src/main/script.sh | bash -s my_role
```
