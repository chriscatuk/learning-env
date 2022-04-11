#cloud-config
repo_update: true
repo_upgrade: all
hostname: ${hostname}

users:
  - name: ${username}
    groups: [ wheel ]
    sudo: [ "ALL=(ALL) NOPASSWD:ALL" ]
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
 - git_repo=https://github.com/repo
 - git_dir=/opt/github/jenkins_install
 - git_branch=main
 - docker_dir=$${git_dir}
# Hostname
 - echo '127.0.0.1 ${hostname}' | sudo tee -a /etc/hosts
 - [ sed, -i, -e, "s/HOSTNAME=.*/HOSTNAME=${hostname}/", /etc/sysconfig/network ]
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
 - curl -L https://github.com/docker/compose/releases/download/1.25.3/docker-compose-`uname -s`-`uname -m` -o /usr/bin/docker-compose
 - chmod +x /usr/bin/docker-compose
 - systemctl enable docker
 - systemctl start docker
# Jenkins
#  - yum -y install java-openjdk
- mkdir /home/jenkins_home
- chmod -R o-rwx /home/jenkins_home
- docker run --restart unless-stopped  -u root -d   -p 8080:8080   -p 50000:50000   --mount type=bind,source=/home/jenkins_home,target=/var/jenkins_home   -v /var/run/docker.sock:/var/run/docker.sock   jenkinsci/blueocean
# Clone repo 2/2: Clone & Install
#  - git clone --depth=1 --branch $${git_branch} $${git_repo} $${git_dir}
#  - cd $${docker_dir}
#  - echo "***** DOCKER SETUP ******"
#  - echo "DNS_ALT_NAMES=${hostname} docker-compose up -d"
#  - DNS_ALT_NAMES=${hostname} docker-compose up -d

power_state:
   delay: "now"
   mode: reboot
   message: Bye Bye
   timeout: 30
