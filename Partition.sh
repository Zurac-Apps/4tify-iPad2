#!/bin/bash
set -e
DEVICE=$1
IP=$2
ps -fA | grep 2022 | grep -v grep | awk '{print $2}' | xargs kill
if [ $DEVICE = "2,2" ];
then
    sleep 2
    echo "Making Temp"
    mkdir -p ~/Desktop/4tifyTemp
    echo "Sending Includes..."
    cd support_files/6.1.3/Includes
    /usr/bin/expect <(cat << EOF
    set timeout -1
    spawn scp -P 22 -o StrictHostKeyChecking=no diskdev-cmds_421.7-4_iphoneos-arm.deb root@$IP:/
    expect "root@$IP's password:"
    send "alpine\r"
    expect eof
    )
    /usr/bin/expect <(cat << EOF
    set timeout -1
    spawn scp -P 22 -o StrictHostKeyChecking=no com.nyansatan.dualbootstuff_1.0.7a.deb root@$IP:/
    expect "root@$IP's password:"
    send "alpine\r"
    expect eof
    )
    /usr/bin/expect <(cat << EOF
    set timeout -1
    spawn scp -P 22 -o StrictHostKeyChecking=no coreutils_8.12-13_iphoneos-arm.deb root@$IP:/
    expect "root@$IP's password:"
    send "alpine\r"
    expect eof
    )
    echo "Installing Includes..."
    /usr/bin/expect <(cat << EOF
    set timeout -1
    spawn ssh -o StrictHostKeyChecking=no -p 22 root@$IP
    expect "root@$IP's password:"
    send "alpine\r"
    expect "#"
    send "dpkg -i /diskdev-cmds_421.7-4_iphoneos-arm.deb\r"
    expect "#"
    send "dpkg -i /com.nyansatan.dualbootstuff_1.0.7a.deb\r"
    expect "#"
    send "dpkg -i /coreutils_8.12-13_iphoneos-arm.deb\r"
    expect "#"
    send "exit\r"
    expect eof
    )
    sleep 2
    echo "Partitioning..."
    /usr/bin/expect <(cat << EOF
    set timeout -1
    spawn ssh -o StrictHostKeyChecking=no -p 22 root@$IP
    expect "root@$IP's password:"
    send "alpine\r"
    expect "#"
    send "TwistedMind2 -d1 3221225472 -s2 879124480 -d2 max\r"
    expect "#"
    send "exit\r"
    expect eof
    )
    sleep 2
    echo "Fetching Patch File"
    srcdirs=$(ssh -n -p 22 root@$IP "find / -name '*TwistedMind2-*'")
    echo "$srcdirs"
    scp -P 22 -o StrictHostKeyChecking=no root@$IP:$srcdirs ~/Desktop/4tifyTemp
    cd ../Ramdisk
    echo "Entering SSH Ramdisk..."
    ./sshtool -k kloader -b pwnediBSS2,2 -p 22 $IP &
    echo "Waiting for Connection, This Might Take Some Time..."
    while !(system_profiler SPUSBDataType 2> /dev/null | grep "Apple Mobile Device (DFU Mode)" 2> /dev/null); do
        sleep 1
    done
    echo "Sending iBEC..."
    ./irecovery -f pwnediBEC2,2
    echo "Please Unplug and Replug Your iPad..."
    while !(system_profiler SPUSBDataType 2> /dev/null | grep "Apple Mobile Device (Recovery Mode)" 2> /dev/null); do
        sleep 1
    done
    /usr/bin/expect <(cat << EOF
    set timeout -1
    spawn  ./irecovery -s
    expect "iRecovery>"
    send "/send devicetree2,2\r"
    expect "iRecovery>"
    send "devicetree\r"
    expect "iRecovery>"
    send "/send ssh_ramdisk\r"
    expect "iRecovery>"
    send "ramdisk\r"
    expect "iRecovery>"
    send "/send kernelcache2,2\r"
    expect "iRecovery>"
    send "bootx\r"
    expect "iRecovery>"
    send "/exit\r"
    expect eof
    )
    echo "Booting..."
    sleep 2
    while !(system_profiler SPUSBDataType 2> /dev/null | grep "iPad" 2> /dev/null); do
        sleep 1
    done
    echo "Establishing Connection (5s)..."
    sleep 5
    ./tcprelay.py > /dev/null 2>&1 -t 22:2022 &
    echo "Establishing Patching Environment (8s)..."
    sleep 8
    echo "Sending dd..."
    sleep 2
    /usr/bin/expect <(cat << EOF
    set timeout -1
    spawn scp -P 2022 -o StrictHostKeyChecking=no dd root@localhost:/bin
    expect "root@localhost's password:"
    send "alpine\r"
    expect eof
    )
    echo "Fetching Patch..."
    echo "Sending patch..."
    sleep 2
    scp -P 2022 -o StrictHostKeyChecking=no  ~/Desktop/4tifyTemp$srcdirs root@localhost:/
    echo "Patching..."
    sleep 2
    /usr/bin/expect <(cat << EOF
    set timeout -1
    spawn ssh -o StrictHostKeyChecking=no -p 2022 root@localhost
    expect "root@localhost's password:"
    send "alpine\r"
    expect "sh-4.0#"
    send "dd if=$srcdirs of=/dev/rdisk0 bs=8192 \r"
    expect "sh-4.0#"
    send "ls -la /dev/disk* \r"
    expect "sh-4.0#"
    send "reboot_bak\r"
    expect eof
    )
    rm -rf ~/Desktop/4tifyTemp
    echo "Done!"
elif [ $DEVICE = "2,1" ];
then
    sleep 2
    echo "Making Temp"
    mkdir -p ~/Desktop/4tifyTemp
    echo "Sending Includes..."
    cd support_files/6.1.3/Includes
    /usr/bin/expect <(cat << EOF
    set timeout -1
    spawn scp -P 22 -o StrictHostKeyChecking=no diskdev-cmds_421.7-4_iphoneos-arm.deb root@$IP:/
    expect "root@$IP's password:"
    send "alpine\r"
    expect eof
    )
    /usr/bin/expect <(cat << EOF
    set timeout -1
    spawn scp -P 22 -o StrictHostKeyChecking=no com.nyansatan.dualbootstuff_1.0.7a.deb root@$IP:/
    expect "root@$IP's password:"
    send "alpine\r"
    expect eof
    )
    /usr/bin/expect <(cat << EOF
    set timeout -1
    spawn scp -P 22 -o StrictHostKeyChecking=no coreutils_8.12-13_iphoneos-arm.deb root@$IP:/
    expect "root@$IP's password:"
    send "alpine\r"
    expect eof
    )
    echo "Installing Includes..."
    /usr/bin/expect <(cat << EOF
    set timeout -1
    spawn ssh -o StrictHostKeyChecking=no -p 22 root@$IP
    expect "root@$IP's password:"
    send "alpine\r"
    expect "#"
    send "dpkg -i /diskdev-cmds_421.7-4_iphoneos-arm.deb\r"
    expect "#"
    send "dpkg -i /com.nyansatan.dualbootstuff_1.0.7a.deb\r"
    expect "#"
    send "dpkg -i /coreutils_8.12-13_iphoneos-arm.deb\r"
    expect "#"
    send "exit\r"
    expect eof
    )
    sleep 2
    echo "Partitioning..."
    /usr/bin/expect <(cat << EOF
    set timeout -1
    spawn ssh -o StrictHostKeyChecking=no -p 22 root@$IP
    expect "root@$IP's password:"
    send "alpine\r"
    expect "#"
    send "TwistedMind2 -d1 3221225472 -s2 879124480 -d2 max\r"
    expect "#"
    send "exit\r"
    expect eof
    )
    sleep 2
    echo "Fetching Patch File"
    srcdirs=$(ssh -n -p 22 root@$IP "find / -name '*TwistedMind2-*'")
    echo "$srcdirs"
    scp -P 22 -o StrictHostKeyChecking=no root@$IP:$srcdirs ~/Desktop/4tifyTemp
    cd ../Ramdisk
    echo "Entering SSH Ramdisk..."
    ./sshtool -k kloader -b pwnediBSS2,1 -p 22 $IP &
    echo "Waiting for Connection, This Might Take Some Time..."
    while !(system_profiler SPUSBDataType 2> /dev/null | grep "Apple Mobile Device (DFU Mode)" 2> /dev/null); do
        sleep 1
    done
    echo "Sending iBEC..."
    ./irecovery -f pwnediBEC2,1
    echo "Please Unplug and Replug Your iPad..."
    while !(system_profiler SPUSBDataType 2> /dev/null | grep "Apple Mobile Device (Recovery Mode)" 2> /dev/null); do
        sleep 1
    done
    /usr/bin/expect <(cat << EOF
    set timeout -1
    spawn  ./irecovery -s
    expect "iRecovery>"
    send "/send devicetree2,1\r"
    expect "iRecovery>"
    send "devicetree\r"
    expect "iRecovery>"
    send "/send ssh_ramdisk\r"
    expect "iRecovery>"
    send "ramdisk\r"
    expect "iRecovery>"
    send "/send kernelcache2,1\r"
    expect "iRecovery>"
    send "bootx\r"
    expect "iRecovery>"
    send "/exit\r"
    expect eof
    )
    echo "Booting..."
    sleep 2
    while !(system_profiler SPUSBDataType 2> /dev/null | grep "iPad" 2> /dev/null); do
        sleep 1
    done
    echo "Establishing Connection (5s)..."
    sleep 5
    ./tcprelay.py > /dev/null 2>&1 -t 22:2022 &
    echo "Establishing Patching Environment (8s)..."
    sleep 8
    echo "Sending dd..."
    sleep 2
    /usr/bin/expect <(cat << EOF
    set timeout -1
    spawn scp -P 2022 -o StrictHostKeyChecking=no dd root@localhost:/bin
    expect "root@localhost's password:"
    send "alpine\r"
    expect eof
    )
    echo "Fetching Patch..."
    echo "Sending patch..."
    sleep 2
    scp -P 2022 -o StrictHostKeyChecking=no  ~/Desktop/4tifyTemp$srcdirs root@localhost:/
    echo "Patching..."
    sleep 2
    /usr/bin/expect <(cat << EOF
    set timeout -1
    spawn ssh -o StrictHostKeyChecking=no -p 2022 root@localhost
    expect "root@localhost's password:"
    send "alpine\r"
    expect "sh-4.0#"
    send "dd if=$srcdirs of=/dev/rdisk0 bs=8192 \r"
    expect "sh-4.0#"
    send "ls -la /dev/disk* \r"
    expect "sh-4.0#"
    send "reboot_bak\r"
    expect eof
    )
    rm -rf ~/Desktop/4tifyTemp
    echo "Done!"
elif [ $DEVICE = "2,3" ];
then
    sleep 2
    echo "Making Temp"
    mkdir -p ~/Desktop/4tifyTemp
    echo "Sending Includes..."
    cd support_files/6.1.3/Includes
    /usr/bin/expect <(cat << EOF
    set timeout -1
    spawn scp -P 22 -o StrictHostKeyChecking=no diskdev-cmds_421.7-4_iphoneos-arm.deb root@$IP:/
    expect "root@$IP's password:"
    send "alpine\r"
    expect eof
    )
    /usr/bin/expect <(cat << EOF
    set timeout -1
    spawn scp -P 22 -o StrictHostKeyChecking=no com.nyansatan.dualbootstuff_1.0.7a.deb root@$IP:/
    expect "root@$IP's password:"
    send "alpine\r"
    expect eof
    )
    /usr/bin/expect <(cat << EOF
    set timeout -1
    spawn scp -P 22 -o StrictHostKeyChecking=no coreutils_8.12-13_iphoneos-arm.deb root@$IP:/
    expect "root@$IP's password:"
    send "alpine\r"
    expect eof
    )
    echo "Installing Includes..."
    /usr/bin/expect <(cat << EOF
    set timeout -1
    spawn ssh -o StrictHostKeyChecking=no -p 22 root@$IP
    expect "root@$IP's password:"
    send "alpine\r"
    expect "#"
    send "dpkg -i /diskdev-cmds_421.7-4_iphoneos-arm.deb\r"
    expect "#"
    send "dpkg -i /com.nyansatan.dualbootstuff_1.0.7a.deb\r"
    expect "#"
    send "dpkg -i /coreutils_8.12-13_iphoneos-arm.deb\r"
    expect "#"
    send "exit\r"
    expect eof
    )
    sleep 2
    echo "Partitioning..."
    /usr/bin/expect <(cat << EOF
    set timeout -1
    spawn ssh -o StrictHostKeyChecking=no -p 22 root@$IP
    expect "root@$IP's password:"
    send "alpine\r"
    expect "#"
    send "TwistedMind2 -d1 3221225472 -s2 879124480 -d2 max\r"
    expect "#"
    send "exit\r"
    expect eof
    )
    sleep 2
    echo "Fetching Patch File"
    srcdirs=$(ssh -n -p 22 root@$IP "find / -name '*TwistedMind2-*'")
    echo "$srcdirs"
    scp -P 22 -o StrictHostKeyChecking=no root@$IP:$srcdirs ~/Desktop/4tifyTemp
    cd ../Ramdisk
    echo "Entering SSH Ramdisk..."
    ./sshtool -k kloader -b pwnediBSS2,3 -p 22 $IP &
    echo "Waiting for Connection, This Might Take Some Time..."
    while !(system_profiler SPUSBDataType 2> /dev/null | grep "Apple Mobile Device (DFU Mode)" 2> /dev/null); do
        sleep 1
    done
    echo "Sending iBEC..."
    ./irecovery -f pwnediBEC2,3
    echo "Please Unplug and Replug Your iPad..."
    while !(system_profiler SPUSBDataType 2> /dev/null | grep "Apple Mobile Device (Recovery Mode)" 2> /dev/null); do
        sleep 1
    done
    /usr/bin/expect <(cat << EOF
    set timeout -1
    spawn  ./irecovery -s
    expect "iRecovery>"
    send "/send devicetree2,3\r"
    expect "iRecovery>"
    send "devicetree\r"
    expect "iRecovery>"
    send "/send ssh_ramdisk\r"
    expect "iRecovery>"
    send "ramdisk\r"
    expect "iRecovery>"
    send "/send kernelcache2,3\r"
    expect "iRecovery>"
    send "bootx\r"
    expect "iRecovery>"
    send "/exit\r"
    expect eof
    )
    echo "Booting..."
    sleep 2
    while !(system_profiler SPUSBDataType 2> /dev/null | grep "iPad" 2> /dev/null); do
        sleep 1
    done
    echo "Establishing Connection (5s)..."
    sleep 5
    ./tcprelay.py > /dev/null 2>&1 -t 22:2022 &
    echo "Establishing Patching Environment (8s)..."
    sleep 8
    echo "Sending dd..."
    sleep 2
    /usr/bin/expect <(cat << EOF
    set timeout -1
    spawn scp -P 2022 -o StrictHostKeyChecking=no dd root@localhost:/bin
    expect "root@localhost's password:"
    send "alpine\r"
    expect eof
    )
    echo "Fetching Patch..."
    echo "Sending patch..."
    sleep 2
    scp -P 2022 -o StrictHostKeyChecking=no  ~/Desktop/4tifyTemp$srcdirs root@localhost:/
    echo "Patching..."
    sleep 2
    /usr/bin/expect <(cat << EOF
    set timeout -1
    spawn ssh -o StrictHostKeyChecking=no -p 2022 root@localhost
    expect "root@localhost's password:"
    send "alpine\r"
    expect "sh-4.0#"
    send "dd if=$srcdirs of=/dev/rdisk0 bs=8192 \r"
    expect "sh-4.0#"
    send "ls -la /dev/disk* \r"
    expect "sh-4.0#"
    send "reboot_bak\r"
    expect eof
    )
    rm -rf ~/Desktop/4tifyTemp
    echo "Done!"
else
    echo "Invalid Option: iPad$DEVICE"
fi
