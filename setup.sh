#!/bin/bash

INFORMATION="\033[01;33m" #yellow
SUCCESS="\033[1;32m"      #green
ERROR="\033[1;31m"        #red
RESET="\033[0;0m"         #white

print_msg() {
  NOW=$(date +%H:%M:%S)
  printf "$1%s ➜ $2$RESET\n" $NOW
}

# START OF THE SCRIPT

if [[ $1 == "" ]]
then
	if [[ $(docker-compose ps | grep -c "transcendence_postgresql") == 0 ]]
	then
		tar -xvf ./PostGresSql/srcs/data.tgz
		docker-compose up
		print_msg $SUCCESS "Transcendence started"

	else print_msg $INFORMATION "Transcendence is already started"
	fi

elif [[ $1 == "stop" ]]
then
	if [[ $(docker-compose ps | grep -c "transcendence") != 0 ]]
	then
		docker-compose down
		docker rmi -f transcendence_postgresql
		docker rmi -f transcendence_web
		tar -czf ./PostGresSql/srcs/data.tgz ./PostGresSql/srcs/data
	
		print_msg $ERROR "Transcendence is stopped"
	else print_msg $INFORMATION "Transcendence is already stopped"
	fi

elif [[ $1 == "restart" ]]
then
		docker-compose down
		docker rmi -f transcendance_postgresql
		docker rmi -f transcendance_web
		tar -czf ./PostGresSql/srcs/data.tgz ./PostGresSql/srcs/data

		tar -xvf ./PostGresSql/srcs/data.tgz
		docker-compose up

		print_msg $RESET "Transcendence has restart"

fi
