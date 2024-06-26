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

dnf install https://rpms.remirepo.net/enterprise/remi-release-8.rpm -y   
validate $? "installing repo from web"

dnf module enable redis:remi-6.2 -y 
validate $? "enabling redis"

dnf install redis -y
validate $? "installing redis"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/redis/redis.conf 
validate $? "changing localhost"
 

systemctl enable redis 
validate $? "enabling redis"

systemctl start redis 
validate $? "starting redis"