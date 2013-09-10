#!/bin/bash
sudo sed -i -e "s/bind-address[ \t]*=.*\$/bind-address = $LOCAL_IP/g" /etc/mysql/my.cnf
sudo service mysql restart
