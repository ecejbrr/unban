#!/bin/bash

# Unban a specific IP address by removing the relevant lines 
# from /etc/hosts.deny and /var/log/auth.log files containing IP.
# Program to be run as root
# Backup copy of original files is kept with current time

usage() {
	echo
	echo "To be run as root"
	echo "$0 <ip_address to unban>"
	echo
}

backup_file(){
	# $1: file to backup
	# $2: IP to unban
	MYDATE=$(date +%Y%m%d_%H%M%S)
	NEWFILE="${1}.b4_unban_${2}.${MYDATE}"
	cp $1 $NEWFILE
	echo $NEWFILE
}


banner_(){
	# $1: text to banner
	chars=$(echo "$1" | wc -c)
	decor=$(for i in $(seq 1 $(echo "$1" | wc -c)); do echo -n "#";done; echo "")
	echo ""
	echo $decor
	echo $1
	echo $decor
}

# root check

[ $EUID -ne 0 ] && { echo "Please run $0 as root"; usage; exit 2; }
# Check argument 

[ $# -ne 1 ] && { echo "Please provide an IP address as argument"; usage; exit 1; }

# Check argument is IP (or almost)

IP2UNBAN=$1
echo $IP2UNBAN | grep -P "\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}" > /dev/null
CHECK_IP="$?"

[ $CHECK_IP -ne 0 ] && { echo "Please provide a valid IP as argument"; usage; exit 3; }


# Remove lines refused connect with matching IP address.

####################
# /var/log/auth.log
####################

TARGETFILE="/var/log/auth.log"
NEWBACKUPFILE=$(backup_file $TARGETFILE $IP2UNBAN)
sed -i -r "/.*sshd.*refused connect.*${IP2UNBAN}/d" $TARGETFILE
banner_ "Lines removed from $TARGETFILE"
diff $TARGETFILE $NEWBACKUPFILE | grep -E "^>" | sed 's/> \(.*\)/\t\1/'

##################
# /etc/hosts.deny
##################

TARGETFILE="/etc/hosts.deny"
NEWBACKUPFILE=$(backup_file $TARGETFILE $IP2UNBAN)
sed -i -r "/.*${IP2UNBAN}.*/d" $TARGETFILE
banner_ "Lines removed from $TARGETFILE"
diff $TARGETFILE $NEWBACKUPFILE | grep -E "^>" | sed 's/> \(.*\)/\t\1/'




#######################
# DENYHOSTS
#######################

# Get denyhosts working dir
work_dir=$(cat /etc/denyhosts.conf | awk -F" ?= ?" '/^WORK_DIR/{print $2}')

[ ! -d ${work_dir}/bak ] && mkdir ${work_dir}/bak 
[ ! -d ${work_dir}/bak ] && { echo "unable to backup denyhosts files"; exit 5; }

for file in $(find ${work_dir} -maxdepth 1 -type f)
do
	TARGETFILE=$file
	MYDATE=$(date +%Y%m%d_%H%M%S)
	NEWBACKUPFILE=${file%/*}/bak/${file##*/}.$MYDATE	
	cp $TARGETFILE $NEWBACKUPFILE
	sed -i -r "/${IP2UNBAN}.*/d" $TARGETFILE
	banner_ "Lines removed from $TARGETFILE"
	diff $TARGETFILE $NEWBACKUPFILE | grep -E "^>" | sed 's/> \(.*\)/\t\1/'
	
done


exit 0
