#!/bin/bash

#Basic LAMP stack setup

#Apache
#Installs Apache and sets up a standard filesystem to track files. Also sets Apache to start on boot.

clear

echo -n "Hello "$USER". 
This script will help setup a basic AMP (Apache, MySQL, PhP) stack.
What will your domain name be? 
Please do not include the .com at the end. 
Press [ENTER] when finished: "
read name

yum install httpd -y
mkdir -p /var/www/vhosts/$name/{admin,ftp,http,https,logs,subdomains}

echo -n "Apache is now installed. 
Directories have been made for the first domain. 
Now we will set up a virtual host.
What will the top level domain be (e.g., .com, .net, .edu)? 
Please do not include the \".\" . "
read tld

echo "
<VirtualHost *:80>
    ServerAdmin webadmin@$name.$tld
    DocumentRoot /var/www/vhosts/$name
    ServerName $name.$tld
    ServerAlias
    ErrorLog /var/www/vhosts/$name/logs/error.log
    CustomLog /var/www/vhosts/$name/logs/access.log common
</VirtualHost>" > /etc/httpd/conf.d/$name.conf

sed -i s/\#NameVirtualHost\ \*\:80/NameVirtualHost\ \*\:80/ /etc/httpd/conf/httpd.conf

service httpd restart
chkconfig httpd on



#IP Tables
#IP Tables will be flushed!!!
#Blocking null Packets, syn-flood, recon packets.
#Localhost opened.
#Prompts issued to open specific ports
#The service will be restarted and the changes will persist a reboot.
echo -n "Now we will setup the IP Tables."
iptables -F

while true; do

	echo -n "What port would you like to open? (Press 'q' to Quit.): " ; read PORT;

	if (("$PORT" < "0")); then
		echo "Invalid Port. Please enter a valid port: "
	elif [ "$PORT" == "q" ]; then
		echo "Thank you. Proceeding to next portion of the installation."
		break
	else
		iptables -A INPUT -p tcp -m tcp --dport "$PORT" -j ACCEPT
	fi

done

echo "Exiting. "

iptables -A INPUT -p tcp --tcp-flags ALL NONE -j DROP
iptables -A INPUT -p tcp ! --syn -m state --state NEW -j DROP
iptables -A INPUT -p tcp --tcp-flags ALL ALL -j DROP
iptables -A INPUT -i lo -j ACCEPT
iptables -I INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -P OUTPUT ACCEPT
iptables -P INPUT DROP
iptables-save | sudo tee /etc/sysconfig/iptables
service iptables restart


#MySQL
#This will install MySQL.
#Need to add lines at the end to do MySQL secure installation since it will pull the user out of the script.

echo -n "Now for MySQL."

yum install mysql-server mysql -y
service mysqld restart



#PhP
#This will install PhP.

echo -n "And finally, PhP."

yum install php php-mysql php-gd php-xml -y

exit
