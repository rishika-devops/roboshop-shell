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

dnf install nginx -y &>> $LOGFILE
validate $? "installing nginx"

systemctl enable nginx &>> $LOGFILE
validate $? "enabling nginx"

systemctl start nginx &>> $LOGFILE
validate $? "starting nginx"

rm -rf /usr/share/nginx/html/* &>> $LOGFILE
validate $? "removing default nginx"

curl -o /tmp/web.zip https://roboshop-builds.s3.amazonaws.com/web.zip &>> $LOGFILE
validate $? "downloading nginx content"

cd /usr/share/nginx/html &>> $LOGFILE
validate $? "changing to nginx directory"

unzip /tmp/web.zip
validate $? "unzipping web content"

cp /home/centos/roboshop-shell/roboshop.conf /etc/nginx/default.d/roboshop.conf 
validate $? "copying reverse proxy information"

systemctl restart nginx 
validate $? "restarting nginx"