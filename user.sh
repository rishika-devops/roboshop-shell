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
validate $? "disabling default version"

dnf module enable nodejs:18 -y &>> $LOGFILE
validate $? "enabling nodejs 18 version"

dnf install nodejs -y &>> $LOGFILE
validate $? "installing nodejs"

useradd roboshop &>> $LOGFILE
validate "adding roboshop user"

mkdir /app &>> $LOGFILE
validate "creating app directory"

curl -L -o /tmp/user.zip https://roboshop-builds.s3.amazonaws.com/user.zip &>> $LOGFILE
validate $? "downloading user code"

cd /app &>> $LOGFILE
validate $? "changing to app directory"

unzip /tmp/user.zip &>> $LOGFILE
validate $? "unzipping user code"

npm install &>> $LOGFILE 
validate $? "installing dependancies"

cp /home/centos/roboshop-shell/user.service /etc/systemd/system/user.service &>> $LOGFILE
validate $? "copying user service"

systemctl daemon-reload &>> $LOGFILE
validate $? "reloading user"

systemctl enable user  &>> $LOGFILE 
validate $? "enabling user"

systemctl start user &>> $LOGFILE
validate $? "starting user"

cp /home/centos/roboshop-shell/mongodb.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE
validate $? "copying mongo repo"

dnf install mongodb-org-shell -y &>> $LOGFILE
validate $? "installing mongodb client"

mongo --host mongodb.sowjanyaaws.xyz </app/schema/user.js &>> $LOGFILE
validate $? "loading default user data"