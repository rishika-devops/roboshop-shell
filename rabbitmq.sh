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

curl -s https://packagecloud.io/install/repositories/rabbitmq/erlang/script.rpm.sh | bash  &>> LOGFILE 
validate $? "downloading repos of erlang rabbitmq"

curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | bash &>> LOGFILE 
validate $? "downloading repos of rabbitmq"

dnf install rabbitmq-server -y &>> LOGFILE 
validate $? "installing rabbitmq" 

systemctl enable rabbitmq-server  &>> LOGFILE 
validate $? "insatlling rabbitmq"

systemctl start rabbitmq-server  &>> LOGFILE 
validate $? "starting rabbitmq"

rabbitmqctl add_user roboshop roboshop123 &>> LOGFILE 
validate $? "adding user and password for rabbitmq"

rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>> LOGFILE 
validate $? "giving permissions to send msgs to all queues"