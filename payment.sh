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

dnf install python36 gcc python3-devel -y &>> $LOGFILE 
validate $? "installing python"

useradd roboshop &>> $LOGFILE  
validate $? "adding roboshop user"

mkdir /app  &>> $LOGFILE
validate $? "creating app directory"

curl -L -o /tmp/payment.zip https://roboshop-builds.s3.amazonaws.com/payment.zip &>> $LOGFILE
validate $? "downloading payment code"

cd /app  &>> $LOGFILE
validate $? "changing to app directory"

unzip /tmp/payment.zip &>> $LOGFILE
validate $? "unzipping payment code"

pip3.6 install -r requirements.txt &>> $LOGFILE
validate $? "installing dependancies"

cp /home/centos/roboshop-shell/payment.service /etc/systemd/system/payment.service &>> $LOGFILE
validate $? "copying payment service"

systemctl daemon-reload &>> $LOGFILE
validate $? "reloading payment"

systemctl enable payment  &>> $LOGFILE
validate $? "enabling payment"

systemctl start payment &>> $LOGFILE
validate $? "starting payment"
