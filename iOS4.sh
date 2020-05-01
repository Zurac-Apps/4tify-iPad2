#!/bin/bash
set -e
DEVICE=$1
OS=$2
IP=$3
if [ $DEVICE = "2,2" ];
then
    if [ $OS = "4.3.3" ];
    then
        cd support_files/4.3.3/Patches2,2
        ./pzb -g 038-1427-003.dmg https://secure-appldnld.apple.com/iPhone4/041-1013.20110503.1m73D/iPad2,2_4.3.3_8J2_Restore.ipsw
        ./dmg extract 038-1427-003.dmg decrypted.dmg -k 990d84816fa06083f4fc778f3e4a03b2bc4e302d8b9998c2ac87d6c0e43cfabc1b0615d4
        ./dmg build decrypted.dmg UDZO.dmg
        echo "Preparing Filesystems..."
        /usr/bin/expect <(cat << EOF
            set timeout -1
            spawn ssh -o StrictHostKeyChecking=no -p 22 root@$IP
            expect "root@$IP's password:"
            send "alpine\r"
            expect "#"
            send "mkdir /mnt1\r"
            expect "#"
            send "mkdir /mnt2\r"
            expect "#"
            send "/sbin/newfs_hfs -s -v System -J -b 8192 -n a=8192,c=8192,e=8192 /dev/disk0s3\r"
            expect "#"
            send "/sbin/newfs_hfs -s -v Data -J -b 8192 -n a=8192,c=8192,e=8192 /dev/disk0s4\r"
            expect "#"
            send "mount_hfs /dev/disk0s4 /mnt2\r"
            expect "#"
            send "exit\r"
            expect eof
        )
        echo "Sending Filesystem, This Will Take A Long Time..."
        /usr/bin/expect <(cat << EOF
        set timeout -1
        spawn scp -P 22 -o StrictHostKeyChecking=no UDZO.dmg root@$IP:/mnt2
        expect "root@$IP's password:"
        send "alpine\r"
        expect eof
        )
        echo "Restoring Filesystem, This Will Take A Long Time..."
        /usr/bin/expect <(cat << EOF
        set timeout -1
        spawn ssh -o StrictHostKeyChecking=no -p 22 root@$IP
        expect "root@$IP's password:"
        send "alpine\r"
        expect "#"
        send "asr restore --source /mnt2/UDZO.dmg --target /dev/disk0s3 --erase\r"
        expect ":"
        send "y\r"
        expect "#"
        send "exit\r"
        expect eof
        )
        echo "Patching Filesystem..."
        /usr/bin/expect <(cat << EOF
        set timeout -1
        spawn ssh -o StrictHostKeyChecking=no -p 22 root@$IP
        expect "root@$IP's password:"
        send "alpine\r"
        expect "#"
        send "fsck_hfs -f /dev/disk0s3\r"
        expect "#"
        send "umount /mnt1\r"
        expect "#"
        send "umount /mnt2\r"
        expect "#"
        send "mount_hfs /dev/disk0s4 /mnt2\r"
        expect "#"
        send "mount_hfs /dev/disk0s3 /mnt1\r"
        expect "#"
        send "mv -v /mnt1/private/var/* /mnt2\r"
        expect "#"
        send "mkdir /mnt2/keybags\r"
        expect "#"
        send "exit\r"
        expect eof
        )
        echo "Patching Fstab..."
        /usr/bin/expect <(cat << EOF
        set timeout -1
        spawn scp -P 22 -o StrictHostKeyChecking=no fstab root@$IP:/mnt1/etc
        expect "root@$IP's password:"
        send "alpine\r"
        expect eof
        )
        echo "Patching Keybag"
        /usr/bin/expect <(cat << EOF
        set timeout -1
        spawn ssh -o StrictHostKeyChecking=no -p 22 root@$IP
        expect "root@$IP's password:"
        send "alpine\r"
        expect "#"
        send "ttbthingy\r"
        expect "#"
        send "fixkeybag -v2\r"
        expect "#"
        send "cp -a /tmp/systembag.kb /mnt2/keybags\r"
        expect "#"
        send "umount /mnt1\r"
        expect "#"
        send "umount /mnt2\r"
        expect "#"
        send "exit\r"
        expect eof
        )
        echo "Patching Boot Files (1/5)"
        /usr/bin/expect <(cat << EOF
        set timeout -1
        spawn scp -P 22 -o StrictHostKeyChecking=no applelogo root@$IP:/
        expect "root@$IP's password:"
        send "alpine\r"
        expect eof
        )
        echo "Patching Boot Files (2/5)"
        /usr/bin/expect <(cat << EOF
        set timeout -1
        spawn scp -P 22 -o StrictHostKeyChecking=no devicetree root@$IP:/
        expect "root@$IP's password:"
        send "alpine\r"
        expect eof
        )
        echo "Patching Boot Files (3/5)"
        /usr/bin/expect <(cat << EOF
        set timeout -1
        spawn scp -P 22 -o StrictHostKeyChecking=no kernelcache root@$IP:/
        expect "root@$IP's password:"
        send "alpine\r"
        expect eof
        )
        echo "Patching Boot Files (4/5)"
        /usr/bin/expect <(cat << EOF
        set timeout -1
        spawn scp -P 22 -o StrictHostKeyChecking=no ramdisk root@$IP:/
        expect "root@$IP's password:"
        send "alpine\r"
        expect eof
        )
        echo "Patching Boot Files (5/5)"
        /usr/bin/expect <(cat << EOF
        set timeout -1
        spawn scp -P 22 -o StrictHostKeyChecking=no LLB root@$IP:/
        expect "root@$IP's password:"
        send "alpine\r"
        expect eof
        )
        echo "Sending runasroot "
        /usr/bin/expect <(cat << EOF
        set timeout -1
        spawn scp -P 22 -o StrictHostKeyChecking=no runasroot root@$IP:/usr/bin
        expect "root@$IP's password:"
        send "alpine\r"
        expect eof
        )
        echo "Sending Boot..."
        /usr/bin/expect <(cat << EOF
        set timeout -1
        spawn scp -P 22 -o StrictHostKeyChecking=no boot.sh root@$IP:/
        expect "root@$IP's password:"
        send "alpine\r"
        expect eof
        )
        cd ../App
        echo "Sending App..."
        /usr/bin/expect <(cat << EOF
        set timeout -1
        spawn scp -P 22 -o StrictHostKeyChecking=no -r 4tify.app root@$IP:/Applications
        expect "root@$IP's password:"
        send "alpine\r"
        expect eof
        )
        echo "Moving Everything Into Place..."
        sleep 2
        /usr/bin/expect <(cat << EOF
        set timeout -1
        spawn ssh -o StrictHostKeyChecking=no -p 22 root@$IP
        expect "root@$IP's password:"
        send "alpine\r"
        expect "#"
        send "chmod 6755 /Applications/4tify.app/4tify\r"
        expect "#"
        send "chmod 4755 /usr/bin/runasroot\r"
        expect "#"
        send "chown root:wheel /usr/bin/runasroot\r"
        expect "#"
        send "chmod 6755 /usr/bin/runasroot\r"
        expect "#"
        send "chmod 6755  /boot.sh\r"
        expect "#"
        send "exit\r"
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
        echo "Rebooting..."
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
    elif [ $OS = "4.3.4" ];
    then
        cd support_files/4.3.4/Patches2,2
        ./pzb -g 038-2180-001.dmg https://secure-appldnld.apple.com/iPhone4/041-1914.20110715.Xdw2Q/iPad2,2_4.3.4_8K2_Restore.ipsw
        ./dmg extract 038-2180-001.dmg decrypted.dmg -k 3907dd20133e8a0bde930d9f3307d3bdf950762c25f8ae7b4f6c8f106949272ccfbf13b0
        ./dmg build decrypted.dmg UDZO.dmg
        echo "Preparing Filesystems..."
        /usr/bin/expect <(cat << EOF
            set timeout -1
            spawn ssh -o StrictHostKeyChecking=no -p 22 root@$IP
            expect "root@$IP's password:"
            send "alpine\r"
            expect "#"
            send "mkdir /mnt1\r"
            expect "#"
            send "mkdir /mnt2\r"
            expect "#"
            send "/sbin/newfs_hfs -s -v System -J -b 8192 -n a=8192,c=8192,e=8192 /dev/disk0s3\r"
            expect "#"
            send "/sbin/newfs_hfs -s -v Data -J -b 8192 -n a=8192,c=8192,e=8192 /dev/disk0s4\r"
            expect "#"
            send "mount_hfs /dev/disk0s4 /mnt2\r"
            expect "#"
            send "exit\r"
            expect eof
        )
        echo "Sending Filesystem, This Will A Take Long Time..."
        /usr/bin/expect <(cat << EOF
        set timeout -1
        spawn scp -P 22 -o StrictHostKeyChecking=no UDZO.dmg root@$IP:/mnt2
        expect "root@$IP's password:"
        send "alpine\r"
        expect eof
        )
        echo "Restoring Filesystem, This Will Take A Long Time..."
        /usr/bin/expect <(cat << EOF
        set timeout -1
        spawn ssh -o StrictHostKeyChecking=no -p 22 root@$IP
        expect "root@$IP's password:"
        send "alpine\r"
        expect "#"
        send "asr restore --source /mnt2/UDZO.dmg --target /dev/disk0s3 --erase\r"
        expect ":"
        send "y\r"
        expect "#"
        send "exit\r"
        expect eof
        )
        echo "Patching Filesystem..."
        /usr/bin/expect <(cat << EOF
        set timeout -1
        spawn ssh -o StrictHostKeyChecking=no -p 22 root@$IP
        expect "root@$IP's password:"
        send "alpine\r"
        expect "#"
        send "fsck_hfs -f /dev/disk0s3\r"
        expect "#"
        send "umount /mnt1\r"
        expect "#"
        send "umount /mnt2\r"
        expect "#"
        send "mount_hfs /dev/disk0s4 /mnt2\r"
        expect "#"
        send "mount_hfs /dev/disk0s3 /mnt1\r"
        expect "#"
        send "mv -v /mnt1/private/var/* /mnt2\r"
        expect "#"
        send "mkdir /mnt2/keybags\r"
        expect "#"
        send "exit\r"
        expect eof
        )
        echo "Patching Fstab..."
        /usr/bin/expect <(cat << EOF
        set timeout -1
        spawn scp -P 22 -o StrictHostKeyChecking=no fstab root@$IP:/mnt1/etc
        expect "root@$IP's password:"
        send "alpine\r"
        expect eof
        )
        echo "Patching Keybag"
        /usr/bin/expect <(cat << EOF
        set timeout -1
        spawn ssh -o StrictHostKeyChecking=no -p 22 root@$IP
        expect "root@$IP's password:"
        send "alpine\r"
        expect "#"
        send "ttbthingy\r"
        expect "#"
        send "fixkeybag -v2\r"
        expect "#"
        send "cp -a /tmp/systembag.kb /mnt2/keybags\r"
        expect "#"
        send "umount /mnt1\r"
        expect "#"
        send "umount /mnt2\r"
        expect "#"
        send "exit\r"
        expect eof
        )
        echo "Patching Boot Files (1/5)"
        /usr/bin/expect <(cat << EOF
        set timeout -1
        spawn scp -P 22 -o StrictHostKeyChecking=no applelogo root@$IP:/
        expect "root@$IP's password:"
        send "alpine\r"
        expect eof
        )
        echo "Patching Boot Files (2/5)"
        /usr/bin/expect <(cat << EOF
        set timeout -1
        spawn scp -P 22 -o StrictHostKeyChecking=no devicetree root@$IP:/
        expect "root@$IP's password:"
        send "alpine\r"
        expect eof
        )
        echo "Patching Boot Files (3/5)"
        /usr/bin/expect <(cat << EOF
        set timeout -1
        spawn scp -P 22 -o StrictHostKeyChecking=no kernelcache root@$IP:/
        expect "root@$IP's password:"
        send "alpine\r"
        expect eof
        )
        echo "Patching Boot Files (4/5)"
        /usr/bin/expect <(cat << EOF
        set timeout -1
        spawn scp -P 22 -o StrictHostKeyChecking=no ramdisk root@$IP:/
        expect "root@$IP's password:"
        send "alpine\r"
        expect eof
        )
        echo "Patching Boot Files (5/5)"
        /usr/bin/expect <(cat << EOF
        set timeout -1
        spawn scp -P 22 -o StrictHostKeyChecking=no LLB root@$IP:/
        expect "root@$IP's password:"
        send "alpine\r"
        expect eof
        )
        echo "Sending runasroot "
        /usr/bin/expect <(cat << EOF
        set timeout -1
        spawn scp -P 22 -o StrictHostKeyChecking=no runasroot root@$IP:/usr/bin
        expect "root@$IP's password:"
        send "alpine\r"
        expect eof
        )
        echo "Sending Boot..."
        /usr/bin/expect <(cat << EOF
        set timeout -1
        spawn scp -P 22 -o StrictHostKeyChecking=no boot.sh root@$IP:/
        expect "root@$IP's password:"
        send "alpine\r"
        expect eof
        )
        cd ../App
        echo "Sending App..."
        /usr/bin/expect <(cat << EOF
        set timeout -1
        spawn scp -P 22 -o StrictHostKeyChecking=no -r 4tify.app root@$IP:/Applications
        expect "root@$IP's password:"
        send "alpine\r"
        expect eof
        )
        echo "Moving Everything Into Place..."
        sleep 2
        /usr/bin/expect <(cat << EOF
        set timeout -1
        spawn ssh -o StrictHostKeyChecking=no -p 22 root@$IP
        expect "root@$IP's password:"
        send "alpine\r"
        expect "#"
        send "chmod 6755 /Applications/4tify.app/4tify\r"
        expect "#"
        send "chmod 4755 /usr/bin/runasroot\r"
        expect "#"
        send "chown root:wheel /usr/bin/runasroot\r"
        expect "#"
        send "chmod 6755 /usr/bin/runasroot\r"
        expect "#"
        send "chmod 6755  /boot.sh\r"
        expect "#"
        send "exit\r"
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
        echo "Rebooting..."
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
    elif [ $OS = "4.3.5" ];
    then
        cd support_files/4.3.5/Patches2,2
        ./pzb -g 038-2278-002.dmg https://secure-appldnld.apple.com/iPhone4/041-1961.20110721.zigyd/iPad2,2_4.3.5_8L1_Restore.ipsw
        ./dmg extract 038-2278-002.dmg decrypted.dmg -k 33774947a7d630a80045e6f3f68005646d84efeedbca70d619a429e10e34696d254812ce
        ./dmg build decrypted.dmg UDZO.dmg
        echo "Preparing Filesystems..."
        /usr/bin/expect <(cat << EOF
            set timeout -1
            spawn ssh -o StrictHostKeyChecking=no -p 22 root@$IP
            expect "root@$IP's password:"
            send "alpine\r"
            expect "#"
            send "mkdir /mnt1\r"
            expect "#"
            send "mkdir /mnt2\r"
            expect "#"
            send "/sbin/newfs_hfs -s -v System -J -b 8192 -n a=8192,c=8192,e=8192 /dev/disk0s3\r"
            expect "#"
            send "/sbin/newfs_hfs -s -v Data -J -b 8192 -n a=8192,c=8192,e=8192 /dev/disk0s4\r"
            expect "#"
            send "mount_hfs /dev/disk0s4 /mnt2\r"
            expect "#"
            send "exit\r"
            expect eof
        )
        echo "Sending Filesystem, This Will A Take Long Time..."
        /usr/bin/expect <(cat << EOF
        set timeout -1
        spawn scp -P 22 -o StrictHostKeyChecking=no UDZO.dmg root@$IP:/mnt2
        expect "root@$IP's password:"
        send "alpine\r"
        expect eof
        )
        echo "Restoring Filesystem, This Will Take A Long Time..."
        /usr/bin/expect <(cat << EOF
        set timeout -1
        spawn ssh -o StrictHostKeyChecking=no -p 22 root@$IP
        expect "root@$IP's password:"
        send "alpine\r"
        expect "#"
        send "asr restore --source /mnt2/UDZO.dmg --target /dev/disk0s3 --erase\r"
        expect ":"
        send "y\r"
        expect "#"
        send "exit\r"
        expect eof
        )
        echo "Patching Filesystem..."
        /usr/bin/expect <(cat << EOF
        set timeout -1
        spawn ssh -o StrictHostKeyChecking=no -p 22 root@$IP
        expect "root@$IP's password:"
        send "alpine\r"
        expect "#"
        send "fsck_hfs -f /dev/disk0s3\r"
        expect "#"
        send "umount /mnt1\r"
        expect "#"
        send "umount /mnt2\r"
        expect "#"
        send "mount_hfs /dev/disk0s4 /mnt2\r"
        expect "#"
        send "mount_hfs /dev/disk0s3 /mnt1\r"
        expect "#"
        send "mv -v /mnt1/private/var/* /mnt2\r"
        expect "#"
        send "mkdir /mnt2/keybags\r"
        expect "#"
        send "exit\r"
        expect eof
        )
        echo "Patching Fstab..."
        /usr/bin/expect <(cat << EOF
        set timeout -1
        spawn scp -P 22 -o StrictHostKeyChecking=no fstab root@$IP:/mnt1/etc
        expect "root@$IP's password:"
        send "alpine\r"
        expect eof
        )
        echo "Patching Keybag"
        /usr/bin/expect <(cat << EOF
        set timeout -1
        spawn ssh -o StrictHostKeyChecking=no -p 22 root@$IP
        expect "root@$IP's password:"
        send "alpine\r"
        expect "#"
        send "ttbthingy\r"
        expect "#"
        send "fixkeybag -v2\r"
        expect "#"
        send "cp -a /tmp/systembag.kb /mnt2/keybags\r"
        expect "#"
        send "umount /mnt1\r"
        expect "#"
        send "umount /mnt2\r"
        expect "#"
        send "exit\r"
        expect eof
        )
        echo "Patching Boot Files (1/5)"
        /usr/bin/expect <(cat << EOF
        set timeout -1
        spawn scp -P 22 -o StrictHostKeyChecking=no applelogo root@$IP:/
        expect "root@$IP's password:"
        send "alpine\r"
        expect eof
        )
        echo "Patching Boot Files (2/5)"
        /usr/bin/expect <(cat << EOF
        set timeout -1
        spawn scp -P 22 -o StrictHostKeyChecking=no devicetree root@$IP:/
        expect "root@$IP's password:"
        send "alpine\r"
        expect eof
        )
        echo "Patching Boot Files (3/5)"
        /usr/bin/expect <(cat << EOF
        set timeout -1
        spawn scp -P 22 -o StrictHostKeyChecking=no kernelcache root@$IP:/
        expect "root@$IP's password:"
        send "alpine\r"
        expect eof
        )
        echo "Patching Boot Files (4/5)"
        /usr/bin/expect <(cat << EOF
        set timeout -1
        spawn scp -P 22 -o StrictHostKeyChecking=no ramdisk root@$IP:/
        expect "root@$IP's password:"
        send "alpine\r"
        expect eof
        )
        echo "Patching Boot Files (5/5)"
        /usr/bin/expect <(cat << EOF
        set timeout -1
        spawn scp -P 22 -o StrictHostKeyChecking=no LLB root@$IP:/
        expect "root@$IP's password:"
        send "alpine\r"
        expect eof
        )
        echo "Sending runasroot "
        /usr/bin/expect <(cat << EOF
        set timeout -1
        spawn scp -P 22 -o StrictHostKeyChecking=no runasroot root@$IP:/usr/bin
        expect "root@$IP's password:"
        send "alpine\r"
        expect eof
        )
        echo "Sending Boot..."
        /usr/bin/expect <(cat << EOF
        set timeout -1
        spawn scp -P 22 -o StrictHostKeyChecking=no boot.sh root@$IP:/
        expect "root@$IP's password:"
        send "alpine\r"
        expect eof
        )
        cd ../App
        echo "Sending App..."
        /usr/bin/expect <(cat << EOF
        set timeout -1
        spawn scp -P 22 -o StrictHostKeyChecking=no -r 4tify.app root@$IP:/Applications
        expect "root@$IP's password:"
        send "alpine\r"
        expect eof
        )
        echo "Moving Everything Into Place..."
        sleep 2
        /usr/bin/expect <(cat << EOF
        set timeout -1
        spawn ssh -o StrictHostKeyChecking=no -p 22 root@$IP
        expect "root@$IP's password:"
        send "alpine\r"
        expect "#"
        send "chmod 6755 /Applications/4tify.app/4tify\r"
        expect "#"
        send "chmod 4755 /usr/bin/runasroot\r"
        expect "#"
        send "chown root:wheel /usr/bin/runasroot\r"
        expect "#"
        send "chmod 6755 /usr/bin/runasroot\r"
        expect "#"
        send "chmod 6755  /boot.sh\r"
        expect "#"
        send "exit\r"
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
        echo "Rebooting..."
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
    else
        echo "Invalid Option: $OS"
    fi
elif [ $DEVICE = "2,1" ];
then
    if [ $OS = "4.3.3" ];
    then
        cd support_files/4.3.3/Patches2,1
        ./pzb -g 038-1425-003.dmg https://secure-appldnld.apple.com/iPhone4/041-1012.20110503.tmmBc/iPad2,1_4.3.3_8J2_Restore.ipsw
        ./dmg extract 038-1425-003.dmg decrypted.dmg -k 7ac7018b57235d34fcbe0c84713ea7c6c482322559336845d299508f6a8643c2078de051
        ./dmg build decrypted.dmg UDZO.dmg
        echo "Preparing Filesystems..."
        /usr/bin/expect <(cat << EOF
            set timeout -1
            spawn ssh -o StrictHostKeyChecking=no -p 22 root@$IP
            expect "root@$IP's password:"
            send "alpine\r"
            expect "#"
            send "mkdir /mnt1\r"
            expect "#"
            send "mkdir /mnt2\r"
            expect "#"
            send "/sbin/newfs_hfs -s -v System -J -b 8192 -n a=8192,c=8192,e=8192 /dev/disk0s3\r"
            expect "#"
            send "/sbin/newfs_hfs -s -v Data -J -b 8192 -n a=8192,c=8192,e=8192 /dev/disk0s4\r"
            expect "#"
            send "mount_hfs /dev/disk0s4 /mnt2\r"
            expect "#"
            send "exit\r"
            expect eof
        )
        echo "Sending Filesystem, This Will Take A Long Time..."
        /usr/bin/expect <(cat << EOF
        set timeout -1
        spawn scp -P 22 -o StrictHostKeyChecking=no UDZO.dmg root@$IP:/mnt2
        expect "root@$IP's password:"
        send "alpine\r"
        expect eof
        )
        echo "Restoring Filesystem, This Will Take A Long Time..."
        /usr/bin/expect <(cat << EOF
        set timeout -1
        spawn ssh -o StrictHostKeyChecking=no -p 22 root@$IP
        expect "root@$IP's password:"
        send "alpine\r"
        expect "#"
        send "asr restore --source /mnt2/UDZO.dmg --target /dev/disk0s3 --erase\r"
        expect ":"
        send "y\r"
        expect "#"
        send "exit\r"
        expect eof
        )
        echo "Patching Filesystem..."
        /usr/bin/expect <(cat << EOF
        set timeout -1
        spawn ssh -o StrictHostKeyChecking=no -p 22 root@$IP
        expect "root@$IP's password:"
        send "alpine\r"
        expect "#"
        send "fsck_hfs -f /dev/disk0s3\r"
        expect "#"
        send "umount /mnt1\r"
        expect "#"
        send "umount /mnt2\r"
        expect "#"
        send "mount_hfs /dev/disk0s4 /mnt2\r"
        expect "#"
        send "mount_hfs /dev/disk0s3 /mnt1\r"
        expect "#"
        send "mv -v /mnt1/private/var/* /mnt2\r"
        expect "#"
        send "mkdir /mnt2/keybags\r"
        expect "#"
        send "exit\r"
        expect eof
        )
        echo "Patching Fstab..."
        /usr/bin/expect <(cat << EOF
        set timeout -1
        spawn scp -P 22 -o StrictHostKeyChecking=no fstab root@$IP:/mnt1/etc
        expect "root@$IP's password:"
        send "alpine\r"
        expect eof
        )
        echo "Patching Keybag"
        /usr/bin/expect <(cat << EOF
        set timeout -1
        spawn ssh -o StrictHostKeyChecking=no -p 22 root@$IP
        expect "root@$IP's password:"
        send "alpine\r"
        expect "#"
        send "ttbthingy\r"
        expect "#"
        send "fixkeybag -v2\r"
        expect "#"
        send "cp -a /tmp/systembag.kb /mnt2/keybags\r"
        expect "#"
        send "umount /mnt1\r"
        expect "#"
        send "umount /mnt2\r"
        expect "#"
        send "exit\r"
        expect eof
        )
        echo "Patching Boot Files (1/5)"
        /usr/bin/expect <(cat << EOF
        set timeout -1
        spawn scp -P 22 -o StrictHostKeyChecking=no applelogo root@$IP:/
        expect "root@$IP's password:"
        send "alpine\r"
        expect eof
        )
        echo "Patching Boot Files (2/5)"
        /usr/bin/expect <(cat << EOF
        set timeout -1
        spawn scp -P 22 -o StrictHostKeyChecking=no devicetree root@$IP:/
        expect "root@$IP's password:"
        send "alpine\r"
        expect eof
        )
        echo "Patching Boot Files (3/5)"
        /usr/bin/expect <(cat << EOF
        set timeout -1
        spawn scp -P 22 -o StrictHostKeyChecking=no kernelcache root@$IP:/
        expect "root@$IP's password:"
        send "alpine\r"
        expect eof
        )
        echo "Patching Boot Files (4/5)"
        /usr/bin/expect <(cat << EOF
        set timeout -1
        spawn scp -P 22 -o StrictHostKeyChecking=no ramdisk root@$IP:/
        expect "root@$IP's password:"
        send "alpine\r"
        expect eof
        )
        echo "Patching Boot Files (5/5)"
        /usr/bin/expect <(cat << EOF
        set timeout -1
        spawn scp -P 22 -o StrictHostKeyChecking=no LLB root@$IP:/
        expect "root@$IP's password:"
        send "alpine\r"
        expect eof
        )
        echo "Sending runasroot "
        /usr/bin/expect <(cat << EOF
        set timeout -1
        spawn scp -P 22 -o StrictHostKeyChecking=no runasroot root@$IP:/usr/bin
        expect "root@$IP's password:"
        send "alpine\r"
        expect eof
        )
        echo "Sending Boot..."
        /usr/bin/expect <(cat << EOF
        set timeout -1
        spawn scp -P 22 -o StrictHostKeyChecking=no boot.sh root@$IP:/
        expect "root@$IP's password:"
        send "alpine\r"
        expect eof
        )
        cd ../App
        echo "Sending App..."
        /usr/bin/expect <(cat << EOF
        set timeout -1
        spawn scp -P 22 -o StrictHostKeyChecking=no -r 4tify.app root@$IP:/Applications
        expect "root@$IP's password:"
        send "alpine\r"
        expect eof
        )
        echo "Moving Everything Into Place..."
        sleep 2
        /usr/bin/expect <(cat << EOF
        set timeout -1
        spawn ssh -o StrictHostKeyChecking=no -p 22 root@$IP
        expect "root@$IP's password:"
        send "alpine\r"
        expect "#"
        send "chmod 6755 /Applications/4tify.app/4tify\r"
        expect "#"
        send "chmod 4755 /usr/bin/runasroot\r"
        expect "#"
        send "chown root:wheel /usr/bin/runasroot\r"
        expect "#"
        send "chmod 6755 /usr/bin/runasroot\r"
        expect "#"
        send "chmod 6755  /boot.sh\r"
        expect "#"
        send "exit\r"
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
        echo "Rebooting..."
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
    elif [ $OS = "4.3.4" ];
    then
        cd support_files/4.3.4/Patches2,1
        ./pzb -g 038-2179-001.dmg https://secure-appldnld.apple.com/iPhone4/041-1924.2011.0715.qP4r3/iPad2,1_4.3.4_8K2_Restore.ipsw
        ./dmg extract 038-2179-001.dmg decrypted.dmg -k dd467a5139d280e60b4ec9bfa534eae9e1d782ee74fcecd86f409e9fe799fb945ee76158
        ./dmg build decrypted.dmg UDZO.dmg
        echo "Preparing Filesystems..."
        /usr/bin/expect <(cat << EOF
            set timeout -1
            spawn ssh -o StrictHostKeyChecking=no -p 22 root@$IP
            expect "root@$IP's password:"
            send "alpine\r"
            expect "#"
            send "mkdir /mnt1\r"
            expect "#"
            send "mkdir /mnt2\r"
            expect "#"
            send "/sbin/newfs_hfs -s -v System -J -b 8192 -n a=8192,c=8192,e=8192 /dev/disk0s3\r"
            expect "#"
            send "/sbin/newfs_hfs -s -v Data -J -b 8192 -n a=8192,c=8192,e=8192 /dev/disk0s4\r"
            expect "#"
            send "mount_hfs /dev/disk0s4 /mnt2\r"
            expect "#"
            send "exit\r"
            expect eof
        )
        echo "Sending Filesystem, This Will Take A Long Time..."
        /usr/bin/expect <(cat << EOF
        set timeout -1
        spawn scp -P 22 -o StrictHostKeyChecking=no UDZO.dmg root@$IP:/mnt2
        expect "root@$IP's password:"
        send "alpine\r"
        expect eof
        )
        echo "Restoring Filesystem, This Will Take A Long Time..."
        /usr/bin/expect <(cat << EOF
        set timeout -1
        spawn ssh -o StrictHostKeyChecking=no -p 22 root@$IP
        expect "root@$IP's password:"
        send "alpine\r"
        expect "#"
        send "asr restore --source /mnt2/UDZO.dmg --target /dev/disk0s3 --erase\r"
        expect ":"
        send "y\r"
        expect "#"
        send "exit\r"
        expect eof
        )
        echo "Patching Filesystem..."
        /usr/bin/expect <(cat << EOF
        set timeout -1
        spawn ssh -o StrictHostKeyChecking=no -p 22 root@$IP
        expect "root@$IP's password:"
        send "alpine\r"
        expect "#"
        send "fsck_hfs -f /dev/disk0s3\r"
        expect "#"
        send "umount /mnt1\r"
        expect "#"
        send "umount /mnt2\r"
        expect "#"
        send "mount_hfs /dev/disk0s4 /mnt2\r"
        expect "#"
        send "mount_hfs /dev/disk0s3 /mnt1\r"
        expect "#"
        send "mv -v /mnt1/private/var/* /mnt2\r"
        expect "#"
        send "mkdir /mnt2/keybags\r"
        expect "#"
        send "exit\r"
        expect eof
        )
        echo "Patching Fstab..."
        /usr/bin/expect <(cat << EOF
        set timeout -1
        spawn scp -P 22 -o StrictHostKeyChecking=no fstab root@$IP:/mnt1/etc
        expect "root@$IP's password:"
        send "alpine\r"
        expect eof
        )
        echo "Patching Keybag"
        /usr/bin/expect <(cat << EOF
        set timeout -1
        spawn ssh -o StrictHostKeyChecking=no -p 22 root@$IP
        expect "root@$IP's password:"
        send "alpine\r"
        expect "#"
        send "ttbthingy\r"
        expect "#"
        send "fixkeybag -v2\r"
        expect "#"
        send "cp -a /tmp/systembag.kb /mnt2/keybags\r"
        expect "#"
        send "umount /mnt1\r"
        expect "#"
        send "umount /mnt2\r"
        expect "#"
        send "exit\r"
        expect eof
        )
        echo "Patching Boot Files (1/5)"
        /usr/bin/expect <(cat << EOF
        set timeout -1
        spawn scp -P 22 -o StrictHostKeyChecking=no applelogo root@$IP:/
        expect "root@$IP's password:"
        send "alpine\r"
        expect eof
        )
        echo "Patching Boot Files (2/5)"
        /usr/bin/expect <(cat << EOF
        set timeout -1
        spawn scp -P 22 -o StrictHostKeyChecking=no devicetree root@$IP:/
        expect "root@$IP's password:"
        send "alpine\r"
        expect eof
        )
        echo "Patching Boot Files (3/5)"
        /usr/bin/expect <(cat << EOF
        set timeout -1
        spawn scp -P 22 -o StrictHostKeyChecking=no kernelcache root@$IP:/
        expect "root@$IP's password:"
        send "alpine\r"
        expect eof
        )
        echo "Patching Boot Files (4/5)"
        /usr/bin/expect <(cat << EOF
        set timeout -1
        spawn scp -P 22 -o StrictHostKeyChecking=no ramdisk root@$IP:/
        expect "root@$IP's password:"
        send "alpine\r"
        expect eof
        )
        echo "Patching Boot Files (5/5)"
        /usr/bin/expect <(cat << EOF
        set timeout -1
        spawn scp -P 22 -o StrictHostKeyChecking=no LLB root@$IP:/
        expect "root@$IP's password:"
        send "alpine\r"
        expect eof
        )
        echo "Sending runasroot "
        /usr/bin/expect <(cat << EOF
        set timeout -1
        spawn scp -P 22 -o StrictHostKeyChecking=no runasroot root@$IP:/usr/bin
        expect "root@$IP's password:"
        send "alpine\r"
        expect eof
        )
        echo "Sending Boot..."
        /usr/bin/expect <(cat << EOF
        set timeout -1
        spawn scp -P 22 -o StrictHostKeyChecking=no boot.sh root@$IP:/
        expect "root@$IP's password:"
        send "alpine\r"
        expect eof
        )
        cd ../App
        echo "Sending App..."
        /usr/bin/expect <(cat << EOF
        set timeout -1
        spawn scp -P 22 -o StrictHostKeyChecking=no -r 4tify.app root@$IP:/Applications
        expect "root@$IP's password:"
        send "alpine\r"
        expect eof
        )
        echo "Moving Everything Into Place..."
        sleep 2
        /usr/bin/expect <(cat << EOF
        set timeout -1
        spawn ssh -o StrictHostKeyChecking=no -p 22 root@$IP
        expect "root@$IP's password:"
        send "alpine\r"
        expect "#"
        send "chmod 6755 /Applications/4tify.app/4tify\r"
        expect "#"
        send "chmod 4755 /usr/bin/runasroot\r"
        expect "#"
        send "chown root:wheel /usr/bin/runasroot\r"
        expect "#"
        send "chmod 6755 /usr/bin/runasroot\r"
        expect "#"
        send "chmod 6755  /boot.sh\r"
        expect "#"
        send "exit\r"
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
        echo "Rebooting..."
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
    elif [ $OS = "4.3.5" ];
    then
        cd support_files/4.3.5/Patches2,1
        ./pzb -g 038-2274-002.dmg https://secure-appldnld.apple.com/iPhone4/041-1960.20110721.UsAO4/iPad2,1_4.3.5_8L1_Restore.ipsw
        ./dmg extract 038-2274-002.dmg decrypted.dmg -k 07a0b5ab0e40ba4f38960274dd8c1db20854159d58761ce98dfa4c50a38b9e786b263607
        ./dmg build decrypted.dmg UDZO.dmg
        echo "Preparing Filesystems..."
        /usr/bin/expect <(cat << EOF
            set timeout -1
            spawn ssh -o StrictHostKeyChecking=no -p 22 root@$IP
            expect "root@$IP's password:"
            send "alpine\r"
            expect "#"
            send "mkdir /mnt1\r"
            expect "#"
            send "mkdir /mnt2\r"
            expect "#"
            send "/sbin/newfs_hfs -s -v System -J -b 8192 -n a=8192,c=8192,e=8192 /dev/disk0s3\r"
            expect "#"
            send "/sbin/newfs_hfs -s -v Data -J -b 8192 -n a=8192,c=8192,e=8192 /dev/disk0s4\r"
            expect "#"
            send "mount_hfs /dev/disk0s4 /mnt2\r"
            expect "#"
            send "exit\r"
            expect eof
        )
        echo "Sending Filesystem, This Will Take A Long Time..."
        /usr/bin/expect <(cat << EOF
        set timeout -1
        spawn scp -P 22 -o StrictHostKeyChecking=no UDZO.dmg root@$IP:/mnt2
        expect "root@$IP's password:"
        send "alpine\r"
        expect eof
        )
        echo "Restoring Filesystem, This Will Take A Long Time..."
        /usr/bin/expect <(cat << EOF
        set timeout -1
        spawn ssh -o StrictHostKeyChecking=no -p 22 root@$IP
        expect "root@$IP's password:"
        send "alpine\r"
        expect "#"
        send "asr restore --source /mnt2/UDZO.dmg --target /dev/disk0s3 --erase\r"
        expect ":"
        send "y\r"
        expect "#"
        send "exit\r"
        expect eof
        )
        echo "Patching Filesystem..."
        /usr/bin/expect <(cat << EOF
        set timeout -1
        spawn ssh -o StrictHostKeyChecking=no -p 22 root@$IP
        expect "root@$IP's password:"
        send "alpine\r"
        expect "#"
        send "fsck_hfs -f /dev/disk0s3\r"
        expect "#"
        send "umount /mnt1\r"
        expect "#"
        send "umount /mnt2\r"
        expect "#"
        send "mount_hfs /dev/disk0s4 /mnt2\r"
        expect "#"
        send "mount_hfs /dev/disk0s3 /mnt1\r"
        expect "#"
        send "mv -v /mnt1/private/var/* /mnt2\r"
        expect "#"
        send "mkdir /mnt2/keybags\r"
        expect "#"
        send "exit\r"
        expect eof
        )
        echo "Patching Fstab..."
        /usr/bin/expect <(cat << EOF
        set timeout -1
        spawn scp -P 22 -o StrictHostKeyChecking=no fstab root@$IP:/mnt1/etc
        expect "root@$IP's password:"
        send "alpine\r"
        expect eof
        )
        echo "Patching Keybag"
        /usr/bin/expect <(cat << EOF
        set timeout -1
        spawn ssh -o StrictHostKeyChecking=no -p 22 root@$IP
        expect "root@$IP's password:"
        send "alpine\r"
        expect "#"
        send "ttbthingy\r"
        expect "#"
        send "fixkeybag -v2\r"
        expect "#"
        send "cp -a /tmp/systembag.kb /mnt2/keybags\r"
        expect "#"
        send "umount /mnt1\r"
        expect "#"
        send "umount /mnt2\r"
        expect "#"
        send "exit\r"
        expect eof
        )
        echo "Patching Boot Files (1/5)"
        /usr/bin/expect <(cat << EOF
        set timeout -1
        spawn scp -P 22 -o StrictHostKeyChecking=no applelogo root@$IP:/
        expect "root@$IP's password:"
        send "alpine\r"
        expect eof
        )
        echo "Patching Boot Files (2/5)"
        /usr/bin/expect <(cat << EOF
        set timeout -1
        spawn scp -P 22 -o StrictHostKeyChecking=no devicetree root@$IP:/
        expect "root@$IP's password:"
        send "alpine\r"
        expect eof
        )
        echo "Patching Boot Files (3/5)"
        /usr/bin/expect <(cat << EOF
        set timeout -1
        spawn scp -P 22 -o StrictHostKeyChecking=no kernelcache root@$IP:/
        expect "root@$IP's password:"
        send "alpine\r"
        expect eof
        )
        echo "Patching Boot Files (4/5)"
        /usr/bin/expect <(cat << EOF
        set timeout -1
        spawn scp -P 22 -o StrictHostKeyChecking=no ramdisk root@$IP:/
        expect "root@$IP's password:"
        send "alpine\r"
        expect eof
        )
        echo "Patching Boot Files (5/5)"
        /usr/bin/expect <(cat << EOF
        set timeout -1
        spawn scp -P 22 -o StrictHostKeyChecking=no LLB root@$IP:/
        expect "root@$IP's password:"
        send "alpine\r"
        expect eof
        )
        echo "Sending runasroot "
        /usr/bin/expect <(cat << EOF
        set timeout -1
        spawn scp -P 22 -o StrictHostKeyChecking=no runasroot root@$IP:/usr/bin
        expect "root@$IP's password:"
        send "alpine\r"
        expect eof
        )
        echo "Sending Boot..."
        /usr/bin/expect <(cat << EOF
        set timeout -1
        spawn scp -P 22 -o StrictHostKeyChecking=no boot.sh root@$IP:/
        expect "root@$IP's password:"
        send "alpine\r"
        expect eof
        )
        cd ../App
        echo "Sending App..."
        /usr/bin/expect <(cat << EOF
        set timeout -1
        spawn scp -P 22 -o StrictHostKeyChecking=no -r 4tify.app root@$IP:/Applications
        expect "root@$IP's password:"
        send "alpine\r"
        expect eof
        )
        echo "Moving Everything Into Place..."
        sleep 2
        /usr/bin/expect <(cat << EOF
        set timeout -1
        spawn ssh -o StrictHostKeyChecking=no -p 22 root@$IP
        expect "root@$IP's password:"
        send "alpine\r"
        expect "#"
        send "chmod 6755 /Applications/4tify.app/4tify\r"
        expect "#"
        send "chmod 4755 /usr/bin/runasroot\r"
        expect "#"
        send "chown root:wheel /usr/bin/runasroot\r"
        expect "#"
        send "chmod 6755 /usr/bin/runasroot\r"
        expect "#"
        send "chmod 6755  /boot.sh\r"
        expect "#"
        send "exit\r"
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
        echo "Rebooting..."
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
    else
        echo "Invalid Option: $OS"
    fi
elif [ $DEVICE = "2,3" ];
then
    if [ $OS = "4.3.4" ];
    then
        cd support_files/4.3.4/Patches2,3
        ./pzb -g 038-2183-001.dmg https://secure-appldnld.apple.com/iPhone4/041-1917.2011.715.ZbLkn/iPad2,3_4.3.4_8K2_Restore.ipsw
        ./dmg extract 038-2183-001.dmg decrypted.dmg -k b314630e05038f97f2d5325b11989634049c5d5d290cc87b9ea7cfd02936b92e76e8f65f
        ./dmg build decrypted.dmg UDZO.dmg
        echo "Preparing Filesystems..."
        /usr/bin/expect <(cat << EOF
            set timeout -1
            spawn ssh -o StrictHostKeyChecking=no -p 22 root@$IP
            expect "root@$IP's password:"
            send "alpine\r"
            expect "#"
            send "mkdir /mnt1\r"
            expect "#"
            send "mkdir /mnt2\r"
            expect "#"
            send "/sbin/newfs_hfs -s -v System -J -b 8192 -n a=8192,c=8192,e=8192 /dev/disk0s3\r"
            expect "#"
            send "/sbin/newfs_hfs -s -v Data -J -b 8192 -n a=8192,c=8192,e=8192 /dev/disk0s4\r"
            expect "#"
            send "mount_hfs /dev/disk0s4 /mnt2\r"
            expect "#"
            send "exit\r"
            expect eof
        )
        echo "Sending Filesystem, This Will Take A Long Time..."
        /usr/bin/expect <(cat << EOF
        set timeout -1
        spawn scp -P 22 -o StrictHostKeyChecking=no UDZO.dmg root@$IP:/mnt2
        expect "root@$IP's password:"
        send "alpine\r"
        expect eof
        )
        echo "Restoring Filesystem, This Will Take A Long Time..."
        /usr/bin/expect <(cat << EOF
        set timeout -1
        spawn ssh -o StrictHostKeyChecking=no -p 22 root@$IP
        expect "root@$IP's password:"
        send "alpine\r"
        expect "#"
        send "asr restore --source /mnt2/UDZO.dmg --target /dev/disk0s3 --erase\r"
        expect ":"
        send "y\r"
        expect "#"
        send "exit\r"
        expect eof
        )
        echo "Patching Filesystem..."
        /usr/bin/expect <(cat << EOF
        set timeout -1
        spawn ssh -o StrictHostKeyChecking=no -p 22 root@$IP
        expect "root@$IP's password:"
        send "alpine\r"
        expect "#"
        send "fsck_hfs -f /dev/disk0s3\r"
        expect "#"
        send "umount /mnt1\r"
        expect "#"
        send "umount /mnt2\r"
        expect "#"
        send "mount_hfs /dev/disk0s4 /mnt2\r"
        expect "#"
        send "mount_hfs /dev/disk0s3 /mnt1\r"
        expect "#"
        send "mv -v /mnt1/private/var/* /mnt2\r"
        expect "#"
        send "mkdir /mnt2/keybags\r"
        expect "#"
        send "exit\r"
        expect eof
        )
        echo "Patching Fstab..."
        /usr/bin/expect <(cat << EOF
        set timeout -1
        spawn scp -P 22 -o StrictHostKeyChecking=no fstab root@$IP:/mnt1/etc
        expect "root@$IP's password:"
        send "alpine\r"
        expect eof
        )
        echo "Patching Keybag"
        /usr/bin/expect <(cat << EOF
        set timeout -1
        spawn ssh -o StrictHostKeyChecking=no -p 22 root@$IP
        expect "root@$IP's password:"
        send "alpine\r"
        expect "#"
        send "ttbthingy\r"
        expect "#"
        send "fixkeybag -v2\r"
        expect "#"
        send "cp -a /tmp/systembag.kb /mnt2/keybags\r"
        expect "#"
        send "umount /mnt1\r"
        expect "#"
        send "umount /mnt2\r"
        expect "#"
        send "exit\r"
        expect eof
        )
        echo "Patching Boot Files (1/5)"
        /usr/bin/expect <(cat << EOF
        set timeout -1
        spawn scp -P 22 -o StrictHostKeyChecking=no applelogo root@$IP:/
        expect "root@$IP's password:"
        send "alpine\r"
        expect eof
        )
        echo "Patching Boot Files (2/5)"
        /usr/bin/expect <(cat << EOF
        set timeout -1
        spawn scp -P 22 -o StrictHostKeyChecking=no devicetree root@$IP:/
        expect "root@$IP's password:"
        send "alpine\r"
        expect eof
        )
        echo "Patching Boot Files (3/5)"
        /usr/bin/expect <(cat << EOF
        set timeout -1
        spawn scp -P 22 -o StrictHostKeyChecking=no kernelcache root@$IP:/
        expect "root@$IP's password:"
        send "alpine\r"
        expect eof
        )
        echo "Patching Boot Files (4/5)"
        /usr/bin/expect <(cat << EOF
        set timeout -1
        spawn scp -P 22 -o StrictHostKeyChecking=no ramdisk root@$IP:/
        expect "root@$IP's password:"
        send "alpine\r"
        expect eof
        )
        echo "Patching Boot Files (5/5)"
        /usr/bin/expect <(cat << EOF
        set timeout -1
        spawn scp -P 22 -o StrictHostKeyChecking=no LLB root@$IP:/
        expect "root@$IP's password:"
        send "alpine\r"
        expect eof
        )
        echo "Sending runasroot "
        /usr/bin/expect <(cat << EOF
        set timeout -1
        spawn scp -P 22 -o StrictHostKeyChecking=no runasroot root@$IP:/usr/bin
        expect "root@$IP's password:"
        send "alpine\r"
        expect eof
        )
        echo "Sending Boot..."
        /usr/bin/expect <(cat << EOF
        set timeout -1
        spawn scp -P 22 -o StrictHostKeyChecking=no boot.sh root@$IP:/
        expect "root@$IP's password:"
        send "alpine\r"
        expect eof
        )
        cd ../App
        echo "Sending App..."
        /usr/bin/expect <(cat << EOF
        set timeout -1
        spawn scp -P 22 -o StrictHostKeyChecking=no -r 4tify.app root@$IP:/Applications
        expect "root@$IP's password:"
        send "alpine\r"
        expect eof
        )
        echo "Moving Everything Into Place..."
        sleep 2
        /usr/bin/expect <(cat << EOF
        set timeout -1
        spawn ssh -o StrictHostKeyChecking=no -p 22 root@$IP
        expect "root@$IP's password:"
        send "alpine\r"
        expect "#"
        send "chmod 6755 /Applications/4tify.app/4tify\r"
        expect "#"
        send "chmod 4755 /usr/bin/runasroot\r"
        expect "#"
        send "chown root:wheel /usr/bin/runasroot\r"
        expect "#"
        send "chmod 6755 /usr/bin/runasroot\r"
        expect "#"
        send "chmod 6755  /boot.sh\r"
        expect "#"
        send "exit\r"
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
        echo "Rebooting..."
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
    elif [ $OS = "4.3.5" ];
    then
        cd support_files/4.3.5/Patches2,3
        ./pzb -g 038-2281-002.dmg https://secure-appldnld.apple.com/iPhone4/041-1962.20110721.rWxrf/iPad2,3_4.3.5_8L1_Restore.ipsw
        ./dmg extract 038-2281-002.dmg decrypted.dmg -k 369474d8df6b2c874a3fb5aa63cf23f7a891363863cf829f7e85ee631318f2674fed6733
        ./dmg build decrypted.dmg UDZO.dmg
        echo "Preparing Filesystems..."
        /usr/bin/expect <(cat << EOF
            set timeout -1
            spawn ssh -o StrictHostKeyChecking=no -p 22 root@$IP
            expect "root@$IP's password:"
            send "alpine\r"
            expect "#"
            send "mkdir /mnt1\r"
            expect "#"
            send "mkdir /mnt2\r"
            expect "#"
            send "/sbin/newfs_hfs -s -v System -J -b 8192 -n a=8192,c=8192,e=8192 /dev/disk0s3\r"
            expect "#"
            send "/sbin/newfs_hfs -s -v Data -J -b 8192 -n a=8192,c=8192,e=8192 /dev/disk0s4\r"
            expect "#"
            send "mount_hfs /dev/disk0s4 /mnt2\r"
            expect "#"
            send "exit\r"
            expect eof
        )
        echo "Sending Filesystem, This Will Take A Long Time..."
        /usr/bin/expect <(cat << EOF
        set timeout -1
        spawn scp -P 22 -o StrictHostKeyChecking=no UDZO.dmg root@$IP:/mnt2
        expect "root@$IP's password:"
        send "alpine\r"
        expect eof
        )
        echo "Restoring Filesystem, This Will Take A Long Time..."
        /usr/bin/expect <(cat << EOF
        set timeout -1
        spawn ssh -o StrictHostKeyChecking=no -p 22 root@$IP
        expect "root@$IP's password:"
        send "alpine\r"
        expect "#"
        send "asr restore --source /mnt2/UDZO.dmg --target /dev/disk0s3 --erase\r"
        expect ":"
        send "y\r"
        expect "#"
        send "exit\r"
        expect eof
        )
        echo "Patching Filesystem..."
        /usr/bin/expect <(cat << EOF
        set timeout -1
        spawn ssh -o StrictHostKeyChecking=no -p 22 root@$IP
        expect "root@$IP's password:"
        send "alpine\r"
        expect "#"
        send "fsck_hfs -f /dev/disk0s3\r"
        expect "#"
        send "umount /mnt1\r"
        expect "#"
        send "umount /mnt2\r"
        expect "#"
        send "mount_hfs /dev/disk0s4 /mnt2\r"
        expect "#"
        send "mount_hfs /dev/disk0s3 /mnt1\r"
        expect "#"
        send "mv -v /mnt1/private/var/* /mnt2\r"
        expect "#"
        send "mkdir /mnt2/keybags\r"
        expect "#"
        send "exit\r"
        expect eof
        )
        echo "Patching Fstab..."
        /usr/bin/expect <(cat << EOF
        set timeout -1
        spawn scp -P 22 -o StrictHostKeyChecking=no fstab root@$IP:/mnt1/etc
        expect "root@$IP's password:"
        send "alpine\r"
        expect eof
        )
        echo "Patching Keybag"
        /usr/bin/expect <(cat << EOF
        set timeout -1
        spawn ssh -o StrictHostKeyChecking=no -p 22 root@$IP
        expect "root@$IP's password:"
        send "alpine\r"
        expect "#"
        send "ttbthingy\r"
        expect "#"
        send "fixkeybag -v2\r"
        expect "#"
        send "cp -a /tmp/systembag.kb /mnt2/keybags\r"
        expect "#"
        send "umount /mnt1\r"
        expect "#"
        send "umount /mnt2\r"
        expect "#"
        send "exit\r"
        expect eof
        )
        echo "Patching Boot Files (1/5)"
        /usr/bin/expect <(cat << EOF
        set timeout -1
        spawn scp -P 22 -o StrictHostKeyChecking=no applelogo root@$IP:/
        expect "root@$IP's password:"
        send "alpine\r"
        expect eof
        )
        echo "Patching Boot Files (2/5)"
        /usr/bin/expect <(cat << EOF
        set timeout -1
        spawn scp -P 22 -o StrictHostKeyChecking=no devicetree root@$IP:/
        expect "root@$IP's password:"
        send "alpine\r"
        expect eof
        )
        echo "Patching Boot Files (3/5)"
        /usr/bin/expect <(cat << EOF
        set timeout -1
        spawn scp -P 22 -o StrictHostKeyChecking=no kernelcache root@$IP:/
        expect "root@$IP's password:"
        send "alpine\r"
        expect eof
        )
        echo "Patching Boot Files (4/5)"
        /usr/bin/expect <(cat << EOF
        set timeout -1
        spawn scp -P 22 -o StrictHostKeyChecking=no ramdisk root@$IP:/
        expect "root@$IP's password:"
        send "alpine\r"
        expect eof
        )
        echo "Patching Boot Files (5/5)"
        /usr/bin/expect <(cat << EOF
        set timeout -1
        spawn scp -P 22 -o StrictHostKeyChecking=no LLB root@$IP:/
        expect "root@$IP's password:"
        send "alpine\r"
        expect eof
        )
        echo "Sending runasroot "
        /usr/bin/expect <(cat << EOF
        set timeout -1
        spawn scp -P 22 -o StrictHostKeyChecking=no runasroot root@$IP:/usr/bin
        expect "root@$IP's password:"
        send "alpine\r"
        expect eof
        )
        echo "Sending Boot..."
        /usr/bin/expect <(cat << EOF
        set timeout -1
        spawn scp -P 22 -o StrictHostKeyChecking=no boot.sh root@$IP:/
        expect "root@$IP's password:"
        send "alpine\r"
        expect eof
        )
        cd ../App
        echo "Sending App..."
        /usr/bin/expect <(cat << EOF
        set timeout -1
        spawn scp -P 22 -o StrictHostKeyChecking=no -r 4tify.app root@$IP:/Applications
        expect "root@$IP's password:"
        send "alpine\r"
        expect eof
        )
        echo "Moving Everything Into Place..."
        sleep 2
        /usr/bin/expect <(cat << EOF
        set timeout -1
        spawn ssh -o StrictHostKeyChecking=no -p 22 root@$IP
        expect "root@$IP's password:"
        send "alpine\r"
        expect "#"
        send "chmod 6755 /Applications/4tify.app/4tify\r"
        expect "#"
        send "chmod 4755 /usr/bin/runasroot\r"
        expect "#"
        send "chown root:wheel /usr/bin/runasroot\r"
        expect "#"
        send "chmod 6755 /usr/bin/runasroot\r"
        expect "#"
        send "chmod 6755  /boot.sh\r"
        expect "#"
        send "exit\r"
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
        echo "Rebooting..."
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
    else
        echo "Invalid Option: $OS"
    fi
else
    echo "Invalid Option: $DEVICE"
fi
