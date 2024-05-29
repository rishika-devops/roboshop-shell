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

dnf install maven -y &>> LOGFILE 
validate $? "installing maven"

id roboshop
if [ $? -ne 0 ]
then
useradd roboshop
validate $? "roboshop user creation"
else
echo -e "$y roboshop user already exists $N"
fi


mkdir -p  /app &>> LOGFILE 
validate $? "creating app directory"

curl -L -o /tmp/shipping.zip https://roboshop-builds.s3.amazonaws.com/shipping.zip &>> LOGFILE 
validate $? "downloading shipping code"

cd /app &>> LOGFILE 
validate $? "changing to app directory"

unzip -o /tmp/shipping.zip &>> LOGFILE 
validate $? "unzipping shipping code"

mvn clean package &>> LOGFILE 
validate $? "installing dependancies"

mv target/shipping-1.0.jar shipping.jar &>> LOGFILE 
validate $? "renaming jar file "

cp /home/centos/roboshop-shell/shipping.service /etc/systemd/system/shipping.service &>> LOGFILE 
validate $? "copying shipping service"

systemctl daemon-reload &>> LOGFILE 
validate $? "realoading shipping"

systemctl enable shipping  &>> LOGFILE 
validate $? "enabling shipping"

systemctl start shipping &>> LOGFILE 
validate $? "starting shipping"

dnf install mysql -y &>> LOGFILE 
validate $? "installing mysql"

mysql -h mysql.sowjanyaaws.online -uroot -pRoboShop@1 < /app/schema/shipping.sql  &>> LOGFILE 
validate $? "logging to mysql and loading shipping data"

systemctl restart shipping &>> LOGFILE 
validate $? "restarting maven"