#!/bin/bash
R="\e[31m"
G="\e[32m"
N="\e[0m"
Y="\e[33m"
TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"
echo "script started executing at $TIMESTAMP"
validate() {
    if [ $1 -ne 0 ]
    then
    echo -e "$R $2 is failed $N"
    else
    echo -e "$G $2 is successful $N"
    fi
}

ID=$(id -u)
if [ $? -ne 0 ]
then 
echo -e "$R error::pls run with root access $N"
exit 1
else
echo "u r a root user"
fi

dnf module disable mysql -y &>> LOGFILE 
validate $? "disbaling current mysql version"

cp /home/centos/roboshop-shell/mysql.repo /etc/yum.repos.d/mysql.repo &>> LOGFILE 
validate $? "copying mysql repo"

dnf install mysql-community-server -y &>> LOGFILE 
validate $? "installing mysql"

systemctl enable mysqld &>> LOGFILE 
validate $? "enabling mysql"

systemctl start mysqld &>> LOGFILE 
validate $? "starting mysql"

mysql_secure_installation --set-root-pass RoboShop@1 &>> LOGFILE 
validate $? "setting mysql password"

