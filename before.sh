#!/bin/bash

. /opt/mfo/common.sh
. /opt/mfo/.dba.aws.key

etee "########################### before.sh ($@) ###########################"
old_master_ppip=$1
old_master_port=$2
new_master_ppip=$3
new_master_port=$4

### Check the number of arguments
if [[ $# < 2 ]]; then
    etee "[BEFORE] Command: $@"
    etee "[BEFORE] At least 2 arguments required: before_failover.sh <old_ip> <old_port> [<new_ip> <new_port>]"
    exit 1
fi

### Fenching IO Out
mysqladmin --login-path=$admin_user -h$old_master_ppip -P$old_master_port --shutdown-timeout=$mysql_timeout shutdown
if [[ $? -ne 0 ]]; then
  etee "[BEFORE] Shutting mysqld down failed or already stopped!"
fi

### Delete VIP from the old master ENI
su $su_user -c "$ssh_cmd $old_master_ppip \"sudo ip addr del $master_cidr dev $master_nic\""
if [[ $? -ne 0 ]]; then
  etee "[BEFORE] Deleting VIP from master NI failed!"
  exit 3
fi
