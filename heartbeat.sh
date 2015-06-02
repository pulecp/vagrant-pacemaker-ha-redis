#!/bin/sh

yum -y update --skip-broken
yum -y install wget vim mlocate

#### install pacemaker
cd /tmp
#tar xvzf /vagrant/pacemaker-1.0.13-2.1.el6.x86_64.repo.tar.gz
#cd pacemaker-1.0.13-2.1.el6.x86_64.repo
#yum -y -c pacemaker.repo install pacemaker-1.0.13-2.el6.x86_64 heartbeat-3.0.5-1.1.el6.x86_64 pm_extras-1.5-1.el6.x86_64

yum -y install pacemaker pssh python-dateutil python-lxml
wget http://download.opensuse.org/repositories/network:/ha-clustering:/Stable/CentOS_CentOS-6/x86_64/crmsh-2.1-1.6.x86_64.rpm
rpm -i crmsh-2.1-1.6.x86_64.rpm

cat /vagrant/redis > /usr/lib/ocf/resource.d/heartbeat/redis
chmod +x /usr/lib/ocf/resource.d/heartbeat/redis

cat /vagrant/corosync.conf > /etc/corosync/corosync.conf
cat /vagrant/authkey > /etc/corosync/authkey
cat /vagrant/pacemaker > /etc/corosync/service.d/pacemaker
cat /vagrant/crm.conf > /etc/crm/crm.conf

### install httpd(Apache)
#yum -y install httpd
#cp /vagrant/index.html /var/www/html

### install redis and listen on all interfaces
yum -y install redis
#sed -i 's/^bind.*/#bind 192.168.1.120/' /etc/redis.conf
cat /vagrant/redis.conf > /etc/redis.conf

### add iptables
iptables -A INPUT -p udp -m udp --dport 694 -j ACCEPT
service iptables save

### add hosts
cat /vagrant/hosts_add >> /etc/hosts

### setting heartbeat
#install /vagrant/ha.cf /etc/ha.d
#install -m 0600 /vagrant/authkeys /etc/ha.d

# kayn's hack
#sed -i '0,/^$/ s|^$|HA_BIN=/usr/lib64/heartbeat|' /etc/init.d/heartbeat
#ln -s /usr/libexec/pacemaker/cib /usr/lib64/heartbeat/cib 
#ln -s /usr/libexec/pacemaker/stonithd /usr/lib64/heartbeat/stonithd 
#ln -s /usr/libexec/pacemaker/attrd /usr/lib64/heartbeat/attrd 
#ln -s /usr/libexec/pacemaker/crmd /usr/lib64/heartbeat/crmd 

### start heartbeat
service pacemaker restart
service corosync restart

