#!/bin/bash

export logfile=/log/mfo/mfo.log
etee() { echo "$@" | tee -a $logfile; }

export ssh_timeout=5
export ssh_port=
export ssh_opt="-p $ssh_port -o StrictHostKeyChecking=no -o PasswordAuthentication=no -o ConnectTimeout=$ssh_timeout -o UserKnownHostsFile=/dev/null -o BatchMode=yes -q"
export ssh_cmd="/usr/bin/ssh $ssh_opt"

export sna_id=
export snb_id=
export rtb_id=

export su_user=
export master_vip=192.168.0.10
export master_pip=$(su $su_user -c "$ssh_cmd $master_vip hostname -I|cut -f1 -d' '|tr -d '\r\n'")
export master_cidr="$master_vip/32"
export master_nic=eth0
export master_port=
export mysql_timeout=5
export admin_user=
export admin_pass=

export MYSQL_TEST_LOGIN_FILE=~/.mylogin.cnf
