#!/bin/bash
set -e
DEVICE=$1
OPTION=$2
cd support_restore/
if [ $DEVICE = "2,2" ];
then
    if [ $OPTION = "A" ];
    then
        echo "Downloading 6.1.3 IPSW..."
        curl -O https://secure-appldnld.apple.com/iOS6.1/091-2472.20130319.Ta4rt/iPad2,2_6.1.3_10B329_Restore.ipsw --progress-bar
        echo "Patching IPSW.."
        ./ipsw iPad2,2_6.1.3_10B329_Restore.ipsw custom.ipsw -memory p0sixspwn.tar ssh_small.tar cydia.tar
        while !(system_profiler SPUSBDataType 2> /dev/null | grep "iPad" 2> /dev/null); do
            sleep 1
            echo "No Device Connected..."
        done
        echo "Fetching Blobs..."
        ./idevicerestore -t custom.ipsw
        ./xpwntool `unzip -j custom.ipsw 'Firmware/dfu/iBSS*' | awk '/inflating/{print $2}'` pwnediBSS
        cd ../support_files/6.1.3/Restore-2,2/A/
        echo "Patching IPSW..."
        zip -d -qq ../../../../support_restore/custom.ipsw "Downgrade/DeviceTree.k94ap.img3"
        zip -d -qq ../../../../support_restore/custom.ipsw "Firmware/all_flash/all_flash.k94ap.production/manifest"
        zip -qq ../../../../support_restore/custom.ipsw Downgrade/DeviceTree.k94ap.img3
        zip -qq ../../../../support_restore/custom.ipsw Firmware/all_flash/all_flash.k94ap.production/manifest
        zip -qq ../../../../support_restore/custom.ipsw Firmware/all_flash/all_flash.k94ap.production/iBoot.img3
        echo "Done!"
    elif [ $OPTION = "B" ];
    then
        echo "Downloading 6.1.3 IPSW..."
        curl -O https://secure-appldnld.apple.com/iOS6.1/091-2472.20130319.Ta4rt/iPad2,2_6.1.3_10B329_Restore.ipsw --progress-bar
        echo "Patching IPSW.."
        ./ipsw iPad2,2_6.1.3_10B329_Restore.ipsw custom.ipsw -memory p0sixspwn.tar ssh_small.tar cydia.tar
        while !(system_profiler SPUSBDataType 2> /dev/null | grep "iPad" 2> /dev/null); do
            sleep 1
             echo "No Device Connected..."
        done
        echo "Fetching Blobs..."
        ./idevicerestore -t custom.ipsw
        ./xpwntool `unzip -j custom.ipsw 'Firmware/dfu/iBSS*' | awk '/inflating/{print $2}'` pwnediBSS
        cd ../support_files/6.1.3/Restore-2,2/B/
        echo "Patching IPSW..."
        zip -d -qq ../../../../support_restore/custom.ipsw "Downgrade/DeviceTree.k94ap.img3"
        zip -d -qq ../../../../support_restore/custom.ipsw "Firmware/all_flash/all_flash.k94ap.production/manifest"
        zip -qq ../../../../support_restore/custom.ipsw Downgrade/DeviceTree.k94ap.img3
        zip -qq ../../../../support_restore/custom.ipsw Firmware/all_flash/all_flash.k94ap.production/manifest
        zip -qq ../../../../support_restore/custom.ipsw Firmware/all_flash/all_flash.k94ap.production/iBoot.img3
        echo "Done!"
    else
        echo "Invalid Option: $OPTION"
    fi
elif [ $DEVICE = "2,1" ];
then
    if [ $OPTION = "A" ];
    then
        echo "Downloading 6.1.3 IPSW..."
        curl -O https://secure-appldnld.apple.com/iOS6.1/091-2397.20130319.EEae9/iPad2,1_6.1.3_10B329_Restore.ipsw --progress-bar
        echo "Patching IPSW.."
        ./ipsw iPad2,1_6.1.3_10B329_Restore.ipsw custom.ipsw -memory p0sixspwn.tar ssh_small.tar cydia.tar
        while !(system_profiler SPUSBDataType 2> /dev/null | grep "iPad" 2> /dev/null); do
            sleep 1
            echo "No Device Connected..."
        done
        echo "Fetching Blobs..."
        ./idevicerestore -t custom.ipsw
        ./xpwntool `unzip -j custom.ipsw 'Firmware/dfu/iBSS*' | awk '/inflating/{print $2}'` pwnediBSS
        cd ../support_files/6.1.3/Restore-2,1/A/
        echo "Patching IPSW..."
        zip -d -qq ../../../../support_restore/custom.ipsw "Downgrade/DeviceTree.k93ap.img3"
        zip -d -qq ../../../../support_restore/custom.ipsw "Firmware/all_flash/all_flash.k93ap.production/manifest"
        zip -qq ../../../../support_restore/custom.ipsw Downgrade/DeviceTree.k93ap.img3
        zip -qq ../../../../support_restore/custom.ipsw Firmware/all_flash/all_flash.k93ap.production/manifest
        zip -qq ../../../../support_restore/custom.ipsw Firmware/all_flash/all_flash.k93ap.production/iBoot.img3
        echo "Done!"
    elif [ $OPTION = "B" ];
    then
        echo "Downloading 6.1.3 IPSW..."
        curl -O https://secure-appldnld.apple.com/iOS6.1/091-2397.20130319.EEae9/iPad2,1_6.1.3_10B329_Restore.ipsw --progress-bar
        echo "Patching IPSW.."
        ./ipsw iPad2,1_6.1.3_10B329_Restore.ipsw custom.ipsw -memory p0sixspwn.tar ssh_small.tar cydia.tar
        while !(system_profiler SPUSBDataType 2> /dev/null | grep "iPad" 2> /dev/null); do
            sleep 1
             echo "No Device Connected..."
        done
        echo "Fetching Blobs..."
        ./idevicerestore -t custom.ipsw
        ./xpwntool `unzip -j custom.ipsw 'Firmware/dfu/iBSS*' | awk '/inflating/{print $2}'` pwnediBSS
        cd ../support_files/6.1.3/Restore-2,1/B/
        echo "Patching IPSW..."
        zip -d -qq ../../../../support_restore/custom.ipsw "Downgrade/DeviceTree.k93ap.img3"
        zip -d -qq ../../../../support_restore/custom.ipsw "Firmware/all_flash/all_flash.k93ap.production/manifest"
        zip -qq ../../../../support_restore/custom.ipsw Downgrade/DeviceTree.k93ap.img3
        zip -qq ../../../../support_restore/custom.ipsw Firmware/all_flash/all_flash.k93ap.production/manifest
        zip -qq ../../../../support_restore/custom.ipsw Firmware/all_flash/all_flash.k93ap.production/iBoot.img3
        echo "Done!"
    else
        echo "Invalid Option: $OPTION"
    fi
elif [ $DEVICE = "2,3" ];
then
    if [ $OPTION = "A" ];
    then
        echo "Downloading 6.1.3 IPSW..."
        curl -O https://secure-appldnld.apple.com/iOS6.1/091-2464.20130319.KF6yt/iPad2,3_6.1.3_10B329_Restore.ipsw --progress-bar
        echo "Patching IPSW.."
        ./ipsw iPad2,3_6.1.3_10B329_Restore.ipsw custom.ipsw -memory p0sixspwn.tar ssh_small.tar cydia.tar
        while !(system_profiler SPUSBDataType 2> /dev/null | grep "iPad" 2> /dev/null); do
            sleep 1
            echo "No Device Connected..."
        done
        echo "Fetching Blobs..."
        ./idevicerestore -t custom.ipsw
        ./xpwntool `unzip -j custom.ipsw 'Firmware/dfu/iBSS*' | awk '/inflating/{print $2}'` pwnediBSS
        cd ../support_files/6.1.3/Restore-2,3/A/
        echo "Patching IPSW..."
        zip -d -qq ../../../../support_restore/custom.ipsw "Downgrade/DeviceTree.k95ap.img3"
        zip -d -qq ../../../../support_restore/custom.ipsw "Firmware/all_flash/all_flash.k95ap.production/manifest"
        zip -qq ../../../../support_restore/custom.ipsw Downgrade/DeviceTree.k95ap.img3
        zip -qq ../../../../support_restore/custom.ipsw Firmware/all_flash/all_flash.k95ap.production/manifest
        zip -qq ../../../../support_restore/custom.ipsw Firmware/all_flash/all_flash.k95ap.production/iBoot.img3
        echo "Done!"
    else
        echo "Invalid Option: $OPTION"
    fi
else
    echo "Invalid Option: iPad$DEVICE"
fi
