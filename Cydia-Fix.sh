#!/bin/bash
set -e
IP=$1
rm ~/.ssh/known_hosts
cd support_files/6.1.3/Includes
echo "Sending Patch..."
/usr/bin/expect <(cat << EOF
set timeout -1
spawn scp -P 22 -o StrictHostKeyChecking=no com.apple.springboard.plist root@$IP:/private/var/mobile/Library/Preferences
expect "root@$IP's password:"
send "alpine\r"
expect eof
)
sleep 2
/usr/bin/expect <(cat << EOF
set timeout -1
spawn ssh -o StrictHostKeyChecking=no -p 22 mobile@$IP
expect "mobile@$IP's password:"
send "alpine\r"
expect "mobile"
send "uicache\r"
expect "mobile"
send "exit\r"
expect eof
)
sleep 2
/usr/bin/expect <(cat << EOF
set timeout -1
spawn ssh -o StrictHostKeyChecking=no -p 22 root@$IP
expect "root@$IP's password:"
send "alpine\r"
expect "#"
send "reboot\r"
expect "#"
send "exit\r"
expect eof
)
echo "Done!"
