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
  - curl
  - stress

runcmd:
  # Clone VPN-Bastion repo 1/2: Settings
  - git_repo=https://github.com/chriscatuk/vpn-bastion.git
  - git_dir=/opt/github/vpn-bastion
  - git_branch=main
  - docker_dir=$${git_dir}/docker-ipsec-vpn-server
  # Hostname
  - echo '127.0.0.1 ${hostname}' | sudo tee -a /etc/hosts
  - [sed, -i, -e, "s/HOSTNAME=.*/HOSTNAME=${hostname}/", /etc/sysconfig/network]
  # Docker
  - amazon-linux-extras install docker -y
  - sudo curl -L https://github.com/docker/compose/releases/download/2.3.3/docker-compose-`uname -s`-`uname -m` -o /usr/bin/docker-compose
  - sudo chmod +x /usr/bin/docker-compose
  - systemctl enable docker
  - systemctl start docker
  - sudo usermod -aG docker ${username} && newgrp docker
  # Clone VPN-Bastion repo 2/2: Clone & Install
  - git clone --depth=1 --branch $${git_branch} $${git_repo} $${git_dir}
  - modprobe af_key
  - cd $${git_dir}
  # Uncomment to build locally instead of using Docker Hub latest version
  # - docker build -t chriscat/ipsec-vpn-server $${docker_dir}
  - echo "      - VPN_PASSWORD=${password}" >> $${docker_dir}/docker-compose.yml
  - echo "      - VPN_IPSEC_PSK=${psk}" >> $${docker_dir}/docker-compose.yml
  - docker-compose -f $${docker_dir}/docker-compose.yml up -d
  # Setup as SSH Jump Server
  - echo 'AcceptEnv AWS_*' >> /etc/ssh/sshd_config
  # Terraform
  - mkdir /opt/tfenv
  - git clone --depth=1 https://github.com/tfutils/tfenv.git /opt/tfenv
  - ln -s /opt/tfenv/bin/* /usr/local/bin
  - tfenv install latest
  - tfenv use latest
  # KUBECTL & HELM
  - mkdir /opt/kubectl
  - curl --fail --silent --show-error -o /opt/kubectl/kubectl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
  - cp /opt/kubectl/kubectl /usr/local/bin/
  - rm -rf /opt/kubectl
  - chmod a+x /usr/local/bin/kubectl
  - export VERIFY_CHECKSUM=false && curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
  # Ansible
  - python3 -m pip --no-cache-dir install ansible botocore boto3 openshift kubernetes
  - mkdir /etc/ansible
  - echo "[defaults]" ] > /etc/ansible/ansible.cfg
  - echo "scp_if_ssh = True" >> /etc/ansible/ansible.cfg
  - echo "interpreter_python=auto_silent" >> /etc/ansible/ansible.cfg

power_state:
  delay: "now"
  mode: reboot
  message: Bye Bye
  timeout: 30
