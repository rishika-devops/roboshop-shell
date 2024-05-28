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
dnf module disable nodejs -y &>> $LOGFILE
validate $? "disabling mnodejs"

dnf module enable nodejs:18 -y &>> $LOGFILE
validate $? "enaling nodejs"

dnf install nodejs -y &>> $LOGFILE
validate $? "installing nodejs"

id roboshop
if [ $? -ne 0 ]
then
useradd roboshop
validate $? "roboshop user creation"
else
echo -e "$y roboshop user already exists $N"
fi

mkdir -p /app &>> $LOGFILE
validate $? "creating app directory"

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip &>> $LOGFILE
validate $? "downloading catalogue code"

cd /app &>> $LOGFILE
validate $? "changing to app dir"
 
unzip -o /tmp/catalogue.zip &>> $LOGFILE
validate $? "unzipping catalogue code"

npm install &>> $LOGFILE
validate $? "installing dependancies"

cp /home/centos/roboshop-shell/catalogue.service /etc/systemd/system/catalogue.service &>> $LOGFILE
validate $? "copying catalogue service"

systemctl daemon-reload &>> $LOGFILE
validate $? "reloading daemon"

systemctl enable catalogue &>> $LOGFILE
validate $? "enabling catalogue"

systemctl start catalogue &>> $LOGFILE
validate $? "starting catalogue"

cp /home/centos/roboshop-shell/mongodb.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE
validate $? "copying mongo repo"

dnf install mongodb-org-shell -y &>> $LOGFILE
validate $? "installing mongo client"

mongo --host mongodb.sowjanyaaws.online </app/schema/catalogue.js &>> $LOGFILE
validate $? "loading catalogue data"