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

cp mongodb.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE
validate $? "copying file"
dnf install mongodb-org -y &>> $LOGFILE
validate $? "installing mongodb"
systemctl enable mongod &>> $LOGFILE
validate $? "enabling mongodb"
systemctl start mongod &>> $LOGFILE
validate $? "starting mongodb"
sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf &>> $LOGFILE
validate $? "changed localhost"
systemctl restart mongod &>> $LOGFILE
validate $? "restarted mongodb"

