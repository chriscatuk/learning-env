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
  - tree

runcmd:
  # Clone repo 1/2: Settings
  - git_repo=https://github.com/puppetlabs/pupperware
  - git_dir=/opt/github/pupperware
  - git_branch=main
  - docker_dir=$${git_dir}
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
  # Puppet Client
  - echo "**************************"
  - echo "*     Puppet Install     *"
  - echo "**************************"
  # - yum -y install puppet-agent # would install the latest (v6)
  - mkdir -p /opt/puppet5_install
  # - wget -P /opt/puppet5_install https://yum.puppet.com/puppet5/puppet5-release-el-8.noarch.rpm
  # - yum install /opt/puppet5_install/puppet5-release-el-8.noarch.rpm -y
  - wget -P /opt/puppet5_install https://yum.puppet.com/puppet5/el/5/x86_64/puppet-agent-5.5.8-1.el5.x86_64.rpm
  - yum install /opt/puppet5_install/puppet-agent-5.5.8-1.el5.x86_64.rpm -y
  - echo "*    Setting up puppet master ${master_hostname}"
  - /opt/puppetlabs/bin/puppet config set server ${master_hostname} --section main
  - echo "*    Start puppet client"
  - /opt/puppetlabs/bin/puppet resource service puppet ensure=running enable=true
  - echo "**************************"
  - echo "*    Puppet Installed    *"
  - echo "**************************"

# Docker
#  - amazon-linux-extras install docker -y
#  - sudo curl -L https://github.com/docker/compose/releases/download/1.24.1/docker-compose-`uname -s`-`uname -m` -o /usr/bin/docker-compose
#  - sudo chmod +x /usr/bin/docker-compose
#  - systemctl enable docker
#  - systemctl start docker
# Clone repo 2/2: Clone & Install
#  - git clone --depth=1 --branch $${git_branch} $${git_repo} $${git_dir}
#  - cd $${docker_dir}
#  - echo "***** DOCKER SETUP ******"
#  - echo "DNS_ALT_NAMES=${hostname} docker-compose up -d"
#  - DNS_ALT_NAMES=${hostname} docker-compose up -d
# Ansible
# - amazon-linux-extras install ansible2 -y
# Terraform
# - wget https://releases.hashicorp.com/terraform/0.12.5/terraform_0.12.5_linux_amd64.zip -qP ~/
# - unzip ~/terraform_0.12.5_linux_amd64.zip -d /usr/local/bin/

power_state:
  delay: "now"
  mode: reboot
  message: Bye Bye
  timeout: 30
