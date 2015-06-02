#!/bin/sh

### wait for being ready cluster
while [ 1 ]
do
  crm node status > /dev/null 2>&1
  if [ $? -eq 0 ]; then
    break
  fi
  sleep 1
done

sleep 30

### setting option
crm configure property stonith-enabled="false"
crm configure property no-quorum-policy="ignore"

### setting resouce
#crm configure primitive redis-node ocf:heartbeat:redis \
#  op start interval="0s" timeout="120s" \
#  op stop interval="0s" timeout="120s" \
#  op monitor interval="20s" timeout="30s"
crm configure primitive p_redis ocf:heartbeat:redis \
        op monitor interval="9" timeout="10" depth="0" \
        op monitor interval="8" role="Master" timeout="10" depth="0" \
        op monitor interval="7" role="Slave" timeout="10" depth="0"

crm configure primitive vip ocf:heartbeat:IPaddr2 \
  params ip="192.168.1.120" nic="eth1" cidr_netmask="24"

crm configure ms ms_redis p_redis \
        meta notify="true" interleave="true"

crm configure colocation redis-vip inf: vip ms_redis:Master

#crm configure group redis-service vip redis-node
#
#crm configure order redis_after_vip inf: vip redis-node
#
#crm configure colocation redis-vip inf: vip redis-node


#property $id="cib-bootstrap-options" \
#        dc-version="1.0.13-a83fae5" \
#        cluster-infrastructure="Heartbeat" \
#        stonith-enabled="false" \
#        no-quorum-policy="ignore" \
#        last-lrm-refresh="1432898163"
#property $id="redis_replication" \
#        p_redis_REPL_INFO="s2
