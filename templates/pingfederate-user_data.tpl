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
  # First line with -e to stop Packer on any error in the script below"
  - "#!/bin/bash -e"
  - echo ' '
  - echo '###########################'
  - echo '#  App Provisioner Begins '
  - echo '###########################'
  - echo ' '
  - set -x
  # Clone repo 1/2: Settings
  - git_repo=https://github.com/pingidentity/pingidentity-devops-getting-started.git
  - git_dir=/opt/github/pingfederate
  - git_branch=master
  - docker_dir=$${git_dir}/11-docker-compose/01-simple-stack/
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
  - sudo curl -L https://github.com/docker/compose/releases/download/1.27.4/docker-compose-`uname -s`-`uname -m` -o /usr/bin/docker-compose
  - sudo chmod +x /usr/bin/docker-compose
  - systemctl enable docker
  - systemctl start docker
  # App
  - sudo curl -sL https://bit.ly/ping-devops-install | bash
  - sudo mv ~/ping-devops /usr/local/bin/.
  - sudo mv ~/bash_profile.ping-devops /usr/local/etc/.
  - echo 'source /usr/local/etc/bash_profile.ping-devops' >> ~/.bash_profile
  - . ~/.bash_profile
  - echo "you can use /usr/local/bin/ping-devops"
  # App container
  - git clone --depth=1 --branch $${git_branch} $${git_repo} $${git_dir}
  - cd $${docker_dir}
  - echo "***** DOCKER SETUP ******"
  - echo docker-compose up -d
  - set +x
  - echo ' '
  - echo '###########################'
  - echo '#  End of the Provisioner  '
  - echo '###########################'
  - echo ' '

power_state:
  delay: "now"
  mode: reboot
  message: Bye Bye
  timeout: 30
