#cloud-config
repo_update: true
repo_upgrade: all
hostname: ${hostname}

users:
  - name: ${username}
    groups: [wheel]
    sudo: ["ALL=(ALL) NOPASSWD:ALL"]
    shell: /bin/bash
    ssh-authorized-keys:
      - ${keypubic}

packages:
  - amazon-efs-utils
  - mtr
  - mailx
  - git
  - python3
  - jq
  - curl
  - stress
  - yum-cron

runcmd:
  -  #!/bin/bash -xe
  - set -xe
  # Clone App repo 1/2: Settings
  - git_repo=https://github.com/chriscatuk/vpn-bastion.git
  - git_dir=/opt/github/vpn-bastion
  - git_branch=master
  - docker_dir=$${git_dir}/docker-ipsec-vpn-server
  # Hostname
  - echo '127.0.0.1 ${hostname}' | sudo tee -a /etc/hosts
  - [sed, -i, -e, "s/HOSTNAME=.*/HOSTNAME=${hostname}/", /etc/sysconfig/network]
  # Yum settings for security updates
  - yum -y update
  - systemctl enable yum-cron
  - sed -i -e 's/apply_updates = no/apply_updates = yes/g' /etc/yum/yum-cron.conf
  - sed -i -e 's/update_cmd = default/update_cmd = security/g' /etc/yum/yum-cron-hourly.conf
  - sed -i -e 's/apply_updates = no/apply_updates = yes/g' /etc/yum/yum-cron-hourly.conf
  - sed -i -e 's/update_messages = no/update_messages = yes/g' /etc/yum/yum-cron-hourly.conf
  - sed -i -e 's/download_updates = no/download_updates = yes/g' /etc/yum/yum-cron-hourly.conf
  - sed -i -e 's/apply_updates = no/apply_updates = yes/g' /etc/yum/yum-cron-hourly.conf
  - systemctl start yum-cron
  # Docker
  - amazon-linux-extras install docker -y
  - sudo curl -L https://github.com/docker/compose/releases/download/2.3.3/docker-compose-`uname -s`-`uname -m` -o /usr/bin/docker-compose
  - sudo chmod +x /usr/bin/docker-compose
  - systemctl enable docker
  - systemctl start docker
  - sudo usermod -aG docker ${username} && newgrp docker
  # Clone App repo 2/2: Clone & Install
  # - git clone --depth=1 --branch $${git_branch} $${git_repo} $${git_dir}
  # - cd $${git_dir}
  # Terraform
  - mkdir /opt/tfenv
  - git clone --depth=1 https://github.com/tfutils/tfenv.git /opt/tfenv
  - ln -s /opt/tfenv/bin/* /usr/local/bin
  - tfenv install latest
  - tfenv use latest
  # KUBECTL & HELM
  - mkdir /opt/kubectl
  - curl --fail --silent --show-error -o /opt/kubectl/kubectl https://amazon-eks.s3.eu-west-1.amazonaws.com/1.21.2/2021-07-05/bin/linux/amd64/kubectl
  - cp /opt/kubectl/kubectl /usr/local/bin/
  - rm -rf /opt/kubectl
  - chmod a+x /usr/local/bin/kubectl
  - export VERIFY_CHECKSUM=false && curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
  # Minikube
  - mkdir /opt/minikube
  - curl --fail --silent --show-error -o /opt/minikube/minikube.rpm https://storage.googleapis.com/minikube/releases/latest/minikube-latest.x86_64.rpm
  - rpm -Uvh /opt/minikube/minikube.rpm
  # Ansible
  - python3 -m pip --no-cache-dir install ansible botocore boto3 openshift kubernetes
  - mkdir /etc/ansible
  - echo "[defaults]" ] > /etc/ansible/ansible.cfg
  - echo "scp_if_ssh = True" ] >> /etc/ansible/ansible.cfg
  - echo "interpreter_python=auto_silent" ] >> /etc/ansible/ansible.cfg

power_state:
  delay: "now"
  mode: reboot
  message: Bye Bye
  timeout: 30
