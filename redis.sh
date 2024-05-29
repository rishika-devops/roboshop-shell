#!/bin/bash
R="\e[31m"
G="\e[32m"
N="\e[0m"
Y="\e[33m"
TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"
exec &>$LOGFILE
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

dnf install https://rpms.remirepo.net/enterprise/remi-release-8.rpm -y  &>> LOGFILE 
validate $? "installing repo from web"

dnf module enable redis:remi-6.2 -y &>> LOGFILE 
validate $? "enabling redis"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/redis/redis.conf &>> LOGFILE 
validate $? "changing localhost"
 

systemctl enable redis &>> LOGFILE 
validate $? "enabling redis"

systemctl start redis &>> LOGFILE 
validate $? "starting redis"