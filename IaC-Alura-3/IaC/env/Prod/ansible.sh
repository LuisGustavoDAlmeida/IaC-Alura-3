#!/bin/bash

cd /home/ubuntu #Indo para a o diretório correto
curl https://bootstrap.pypa.io/get-pip.py -o get pip.py # Pegando o arquivo
sudo python3 get-pip.py # Executando o arquivo pego acima
sudo python3 -m pip install ansible # Instalando Ansible através do Python
tee -a playbook.yml > /dev/null <<EOT ## Adiciona um conteúdo de um bloco de texto delimitado até o EOT sem imprimir nada na saída

- hosts: localhost
  tasks: 
  - name: Instalando python3, virtualenv
    apt: 
      pkg:
      - python3
      - virtualenv
      update_cache: yes # Parecido com o apt upgrade/update
    become: yes # Executar as coisas como superusuário (root)
  - name: Git Clone
    ansible.builtin.git: # Git dentro do ansible
      repo: https://github.com/alura-cursos/clientes-leo-api.git # Repositório
      dest: /home/ubuntu/tcc # Destino da pasta
      version: master # Branch do repositório
      force: yes # Forçar a pegar a versão mais atualizada
  - name: Instalando dependências com pip (Django e Django Rest)
    pip: 
      virtualenv: /home/ubuntu/tcc/venv
      requirements: /home/ubuntu/tcc/requirements.txt
  - name: Alterando o hosts do settings
    lineinfile: 
      path: /home/ubuntu/tcc/setup/settings.py
      regexp: 'ALLOWED_HOSTS' # Uma crase no início poderiamos alterar todos os lugares que teriam esse trecho
      line: 'ALLOWED_HOSTS = ["*"]' # Permitindo todas as máquinas
      backrefs: yes # Caso ele não ache o arquivo ele não irá fazer nada
  - name: config BD
    shell: '. /home/ubuntu/tcc/venv/bin/activate; python3.12 -m pip install --upgrade pip setuptools; python /home/ubuntu/tcc/manage.py migrate'
  - name: Iniciando dados
    shell: '. /home/ubuntu/tcc/venv/bin/activate; python /home/ubuntu/tcc/manage.py loaddata clientes.json'
  - name: Startando server
    shell: '. /home/ubuntu/tcc/venv/bin/activate; nohup python /home/ubuntu/tcc/manage.py runserver 0.0.0.0:8000 &'
EOT
ansible-playbook playbook.ymlS