#!/bin/bash
set -e
IP=$1
cd support_restore/
./sshtool -k kloader -b pwnediBSS -p 22 $IP &
while !(system_profiler SPUSBDataType 2> /dev/null | grep " Apple Mobile Device" 2> /dev/null); do
    sleep 1
done
set +e
./idevicerestore -e -w custom.ipsw
echo "Done!"
