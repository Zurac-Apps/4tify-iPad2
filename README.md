# 4tify-iPad2 v1.3.1
You can once again enjoy the greatest iOS on your iPad 2. By @zzanehip.

## What and Why?

* When the iPad 2 first came out in 2011, my grandmother bought me one for my birthday — I became enamoured with the device the momenent I began to use it. For this reason it has always been a special device for me. 
* Most people don't have blobs saved for their iPad 2, and thus had no way to get back to iOS 4.
* The goal in this project is to two fold: to allow people to run iOS 4 on their iPad 2, and to make running it a convient reality.
* I hope this brings a little you a little joy while you're cooped up inside ;)   
* ***This is still very much an early phase project, use this at your own risk. Before continuing, please read the "What's Supported" and "Current Issues" sections.***

## What's Supported
There is still further testing to be done on this issue, but as of right now it appears your iPad must have at one point ran iOS 4.3.x. Not compeletly sure though, so if your iPad was built past September 2011, go ahead and give it a try, and report back.

* iPad 2 Wifi (2,1)
	* iOS 4.3 - 4.3.5
		* Fully working	 
* iPad 2 GSM (2,2)
 	* iOS 4.3 - 4.3.5
		* Fully working
* iPad 2 CDMA (2,3)
 	* iOS 4.3 - 4.3.5
		* Fully working
* Tested on Mac OS 10.9-10.15


#  Instructions:

- Before starting, ensure your iPad is Jailbroken with a tfp0 exploit, and OpenSSH + Core Utilities + Core Utilities (/bin) installed.
- While conducting the process, keep your iPad plugged into your computer (obviously).
- Keep your root password as alpine throughout the process. 
- As always, if one of the scripts refuses to run (permission denied) just run chmod +x on it.
- Don't come yelling at me if your iPad 2 is not compatible. Be smart, check sndeep.info if you're not certain. 

##  1. Restore and Jailbreak:
We need to get our iPad onto a modified version of iOS 6.1.3 with lwvm patched out and replaced with GPT.

1. First, build patched IPSW and grab blobs (of course, omit < > when entering). For model enter either 2,1 2,2 or 2,3:

`./Create-Restore <Model>`

2. Restore to IPSW (Enter root password, alpine, when asked):		

`./Restore <Model> <IP-Address>`

3. Set up your device.

4. A Jailbreak is prebuilt into the IPSW, but you wont see the Cydia app. To fix this run:

`./Cydia-Fix <IP-Address>`	

5. Done, you should see Cydia on your Springboard, open it, and let it do it's thing. Once it's done, reboot your device (Cydia wont open if you don't). Open Cydia, upgrade essential. Do not do complete upgrade, ever!

##  2. iOS 4 and the Second Partition:
Now, we'll partition our device, install iOS 4, and patch it. Once this is done, you'll be good to go!

1. First, we'll install necesary files, partition the device, and patch it. (It will ask for your root password a few times, as always, enter alpine. Again, If the  process doesn't continue after e.g. fish: storing file 73728 (73728) just click your home button):

`./Partition <Model> <IP-Address>`

2. Lastly, we'll initalize our partition, build our filesystem, restore it, and patch it:	

`./iOS4 <IP-Address>`

3. That's it, your done, and your device will reboot. To boot into iOS 4, lauch the 4tify app. Once your screen goes black wait a sec, then tap your homebutton, and should see your device start to verbose boot within 10-15 seconds.

4. If you delete the 4tify app, or it doesn't seem to be working, you can always run:

`./Reinstall-App <IP-Address>`

****As of right now, modifying your iOS 4 password is dangerous, and will likely result in a recovery loop. Until this is fixed, do not set it!***

## Current Issues
* ***iPad 2,2 and 2,3 Baseband Acitvation***
	* On some iPad 2,2 and 2,3s there seems to be an baseband issue that prevents the device from activating. Not sure what the root cause of it is yet, but it shoudn't take too long to figure it out. 

## Changelog
	* 1.3.1 - Resolves compiler issue.
	* 1.3 - Major update. 
		* Supports all versions of iOS 4.3 and Jailbreaking. 
		* All scripts rebuilt in C with stability and speed in mind.
		* Rebuilt various parts of the restore process (custom loader, idevicerestore, restore components, and framebuffer)
		* Resolved major iOS 4 boot issues plaguing all devices.
		* Added write-up for how to resolve NAND WMR/FTL Error.
		* Other neat features, bug fixes, and performance updates.
	* 1.2 — Stability improvements and GSM/CDMA revisions. 
	* 1.1 — New boot method fixes black screen issue. 
	* 1.0B — Release. 


## Thanks to:
* @Nyansatan for dualbootstuff package.
* @axi0mX for tons of help along the way.
* @JonathanSeals for help along the way.
* @winocm and @xerub for kloader.
* @dayt0n for Odysseus.
* @thimstar for OdysseusOTA.
* @ShadowLee19 for useful info. 
* @msft_guy for ssh ramdisk.
* @Billy-Ellis for runasroot.
* @Exploite-d for ssh_ramdisk exec.
* @synackuk for framebuffer info.
* @Tommymossss for entertaining me while I made this.
 
