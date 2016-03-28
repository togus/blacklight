#install mysql and conf master/slave
#Fixa så yum auto yesar
wget http://dev.mysql.com/get/mysql57-community-release-el6-7.noarch.rpm
yum -y localinstall mysql57-community-release-el6-7.noarch.rpm
yum -y install mysql-community-server

SERVER_COUNT=$(cat /tmp/mysql-server-count | tr -d '\n')

/etc/init.d/mysqld start --bind-address=0.0.0.0 --gtid-mode=ON --log-bin --enforce-gtid-consistency --server-id=1$SERVER_COUNT  


#we shouldn't autostart a mysql on startup due to incase it thinks it is a master 
#sudo service mysqld start
#sudo chkconfig mysqld on
#chkconfig --list mysqld



#
iptables -I INPUT -s 0/0 -p tcp --dport 3306 -j ACCEPT

#to get the mysql temp password
#grep 'temporary password' /var/log/mysqld.log

#I Hope the passwords can't have any spaces in them
TEMP_PASSWORD=$(grep 'temporary password' /var/log/mysqld.log | cut -d ':' -f4 | tr -d ' ')

#Exec slave/master.sql with temp password, new password will be set in the master.sql
if [[ $SERVER_COUNT -eq 0 ]]; then
    #The first server is the master
    mysql --password="$TEMP_PASSWORD" --connect-expired-password < /tmp/scripts/master.sql 
else
    #All other servers will be slaves
    mysql --password="$TEMP_PASSWORD" --connect-expired-password < /tmp/scripts/slave.sql 
fi
#sudo /usr/bin/mysqladmin -u root password 'DevOps123!'
#OR ALTER USER 'root'@'localhost' IDENTIFIED BY 'DevOps123!';

##Install consul and join as agent
echo "Fetching Consul..."
CONSUL=0.6.4
cd /tmp
wget https://releases.hashicorp.com/consul/${CONSUL}/consul_${CONSUL}_linux_amd64.zip -O consul.zip

echo "Installing Consul..."
unzip consul.zip >/dev/null
chmod +x consul
sudo mv consul /usr/local/bin/consul
sudo mkdir -p /opt/consul/data

CONSUL_JOIN=$(cat /tmp/consul-server-addr | tr -d '\n')

# Write the flags to a temporary file
cat >/tmp/consul_flags << EOF
CONSUL_FLAGS="-join=${CONSUL_JOIN} -data-dir=/opt/consul/data"
EOF

echo "Installing consul as an upstart service..."
mkdir -p /etc/consul.d
mkdir -p /etc/service
chown root:root /tmp/scripts/rhel_upstart.conf
mv /tmp/scripts/rhel_upstart.conf /etc/init/consul.conf
sudo chmod 0644 /etc/init/consul.conf
mv /tmp/consul_flags /etc/service/consul
chmod 0644 /etc/service/consul
start consul
