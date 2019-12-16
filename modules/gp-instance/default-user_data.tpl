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
 - echo '127.0.0.1 ${hostname}' | sudo tee -a /etc/hosts
 - [ sed, -i, -e, "s/HOSTNAME=.*/HOSTNAME=${hostname}/", /etc/sysconfig/network ]
 - yum -y update
 - systemctl enable yum-cron
 - sed -i -e 's/apply_updates = no/apply_updates = yes/g' /etc/yum/yum-cron.conf
 - sed -i -e 's/update_cmd = default/update_cmd = security/g' /etc/yum/yum-cron-hourly.conf
 - sed -i -e 's/apply_updates = no/apply_updates = yes/g' /etc/yum/yum-cron-hourly.conf
 - sed -i -e 's/update_messages = no/update_messages = yes/g' /etc/yum/yum-cron-hourly.conf
 - sed -i -e 's/download_updates = no/download_updates = yes/g' /etc/yum/yum-cron-hourly.conf
 - sed -i -e 's/apply_updates = no/apply_updates = yes/g' /etc/yum/yum-cron-hourly.conf
 - systemctl start yum-cron

power_state:
   delay: "now"
   mode: reboot
   message: Bye Bye
   timeout: 30
