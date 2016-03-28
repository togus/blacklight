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
#--------


if [[ $SERVER_COUNT -eq 0 ]]; then
    #The first server is the master
    mysql --password="$TEMP_PASSWORD" --connect-expired-password < /tmp/scripts/master.sql 
else
    #All other servers will be slaves
    mysql --password="$TEMP_PASSWORD" --connect-expired-password < /tmp/scripts/slave.sql 
fi


#sudo /usr/bin/mysqladmin -u root password 'DevOps123!'
#OR ALTER USER 'root'@'localhost' IDENTIFIED BY 'DevOps123!';


#If master
#   Get data for variables
#   Conf the master stuff for mysql
#   Create database
#   Lock, dump and send it to slave

#else slave
#
#
#

