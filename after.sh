#!/bin/bash

. /opt/mfo/common.sh
. /opt/mfo/.dba.aws.key

etee "########################### after.sh ($@) ###########################"
old_master_ppip=$1
old_master_port=$2
new_master_ppip=$3
new_master_port=$4

new_master_id=$(aws ec2 describe-instances --filter Name=network-interface.addresses.private-ip-address,Values=$new_master_ppip --query Reservations[].Instances[].InstanceId --output text)

### Check the number of arguments
if [[ $# -ne 4 ]]; then
    etee "[AFTER] Command: $@" >&2
    etee "[AFTER] Exactly 4 arguments required: after_failover.sh <old_ip> <old_port> <new_ip> <new_port>" >&2
    exit 1
fi

### ADD VIP to the new master ENI
su $su_user -c "$ssh_cmd $new_master_ppip \"sudo ip addr add $master_cidr dev $master_nic\""
if [[ $? -ne 0 ]]; then
  etee "[AFTER] Adding VIP to new master NI failed or already exists!"
fi

### Replace Route
aws ec2 replace-route --route-table-id $rtb_id --destination-cidr-block $master_cidr --instance-id $new_master_id
### Rollback
# aws ec2 replace-route --route-table-id $rtb_id --destination-cidr-block $master_cidr --instance-id $old_master_id
if [[ $? -ne 0 ]]; then
  etee "[AFTER] Replacing routing tables failed!"
  exit 4
fi

### Enable mysql write
mysql --login-path=$admin_user -h$new_master_ppip -P$new_master_port -e"set global read_only=0"
if [[ $? -ne 0 ]]; then
  etee "[AFTER] Setting Master to Read-Write failed!"
  exit 5
fi
