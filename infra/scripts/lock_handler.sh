#!/bin/bash
#Simple stuff...
IPADDRESS=$(/sbin/ifconfig | grep "inet addr:" | grep "Bcast:" | cut -d":" -f2 | cut -d" " -f1)

mysql --password="DevOps123!" --connect-expired-password < /tmp/scripts/master.sql

curl -X PUT -d $HOSTNAME http://localhost:8500/v1/kv/service/mysql/master/hostname
curl -X PUT -d $IPADDRESS http://localhost:8500/v1/kv/service/mysql/master/ipaddress

while [ ! -f /tmp/UNLOCK_MASTER ];
do
   sleep 2
done

curl -X DELETE http://localhost:8500/v1/kv/service/mysql/master/hostname
curl -X DELETE http://localhost:8500/v1/kv/service/mysql/master/ipaddress

service mysqld stop
echo "the master is down.. someone else need to take the lock and become the new master"