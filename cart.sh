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

dnf module disable nodejs -y &>> LOGFILE 
validate $? "disabling current nodejs version"

dnf module enable nodejs:18 -y &>> LOGFILE 
validate $? "enabling  nodejs 18 version"

dnf install nodejs -y &>> LOGFILE 
validate $? "installing nodejs version"

useradd roboshop &>> LOGFILE 
validate $? "adding roboshop user"

mkdir /app &>> LOGFILE 
validate $? "creating app directory"

curl -L -o /tmp/cart.zip https://roboshop-builds.s3.amazonaws.com/cart.zip &>> LOGFILE 
validate $? "downloading cart code"

cd /app &>> LOGFILE 
validate $? "changing to app directory"

unzip /tmp/cart.zip &>> LOGFILE  
validate $? "unzipping cart code"

npm install &>> LOGFILE 
validate $? "installing dependancies"

cp /home/centos/roboshop-shell/cart.service /etc/systemd/system/cart.service &>> LOGFILE 
validate $? "copying cart service"

systemctl daemon-reload &>> LOGFILE 
validate $? "reloading cart"

systemctl enable cart  &>> LOGFILE 
validate $? "enabling cart"

systemctl start cart &>> LOGFILE 
validate $? "starting cart"