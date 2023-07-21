#cloud-config
repo_update: true
repo_upgrade: all
hostname: ${hostname}

users:
  - name: ${username}
    groups: wheel
    sudo: ALL=(ALL) NOPASSWD:ALL
    shell: /bin/bash
    ssh-authorized-keys:
      - ${keypubic}

packages:
  - amazon-efs-utils
  - mtr
  - mailx
  - git
  - python3
  - python3-pip
  - jq
  - stress
  - java-11-amazon-corretto
  - vim
  - docker
  - unzip

runcmd:
  # Clone App repo 1/2: Settings
  - git_repo=https://github.com/chriscatuk/learning-env.git
  - git_dir=/opt/github/learning-env
  - git_branch=main
  - docker_dir=$${git_dir}/templates
  # Hostname
  - echo '127.0.0.1 ${hostname}' | sudo tee -a /etc/hosts
  - [sed, -i, -e, "s/HOSTNAME=.*/HOSTNAME=${hostname}/", /etc/sysconfig/network]
  # Docker
  - sudo curl --fail --silent --show-error  -L https://github.com/docker/compose/releases/download/v2.20.1/docker-compose-linux-x86_64 -o /usr/bin/docker-compose
  - sudo chmod +x /usr/bin/docker-compose
  - systemctl enable docker
  - systemctl start docker
  - sudo usermod -aG docker ${username} && newgrp docker
  # Clone App repo 2/2: Clone & Install
  # - git clone --depth=1 --branch $${git_branch} $${git_repo} $${git_dir}
  # - cd $${git_dir}
  # Terraform
  # - mkdir /opt/tfenv
  # - git clone --depth=1 https://github.com/tfutils/tfenv.git /opt/tfenv
  # - ln -s /opt/tfenv/bin/* /usr/local/bin
  # - tfenv install latest
  # - tfenv use latest
  # KUBECTL & HELM
  - mkdir /opt/kubectl
  - curl --fail --silent --show-error -o /opt/kubectl/kubectl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
  - cp /opt/kubectl/kubectl /usr/local/bin/
  - rm -rf /opt/kubectl
  - chmod a+x /usr/local/bin/kubectl
  - export VERIFY_CHECKSUM=false && curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
  # Minikube
  - mkdir /opt/minikube
  - curl --fail --silent --show-error -o /opt/minikube/minikube.rpm https://storage.googleapis.com/minikube/releases/latest/minikube-latest.x86_64.rpm
  - rpm -Uvh /opt/minikube/minikube.rpm
  # K9S
  - curl -sS https://webinstall.dev/k9s | bash
  # Ansible
  # - python3 -m pip --no-cache-dir install ansible botocore boto3 openshift kubernetes
  # - mkdir /etc/ansible
  # - echo "[defaults]" ] > /etc/ansible/ansible.cfg
  # - echo "scp_if_ssh = True" >> /etc/ansible/ansible.cfg
  # - echo "interpreter_python=auto_silent" >> /etc/ansible/ansible.cfg
  # MariaDB
  # - minikube start
  # - kubectl run mariadb-test-pod --image=mariadb --env="MARIADB_ROOT_PASSWORD=secret"
  # Run select commands
  # - kubectl exec -it mariadb-test-pod -- mariadb -uroot -psecret -e "select current_user()"

power_state:
  delay: "now"
  mode: reboot
  message: Bye Bye
  timeout: 30
