# 4tify-iPad2 v1.0
You can once again enjoy the greatest iOS on your iPad 2. By @zzanehip.

## What and Why?

* When the iPad 2 first came out in 2011, my grandmother bought me one for my birthday — I became enamoured with the device the momenent I began to use it. For this reason it has always been a special device for me. 
* Most people don't have blobs saved for their iPad 2, and thus had no way to get back to iOS 4.
* The goal in this project is to two fold: to allow people to run iOS 4 on their iPad 2, and to make running it a convient reality.
* I hope this brings a little you a little joy while you're cooped up inside ;)   
* ***This is still very much an early phase project, use this at your own risk. Before continuing, please read the "What's Supported" and "Current Issues" sections.***

## What's Supported
There is still further testing to be done on this issue, but as of right now it appears your iPad must have at one point ran iOS 4.3.x. 

* iPad 2 Wifi (2,1)
	* iOS 4.3.4
		* Partially working (see Current Issues)
	* iOS 4.3.5
		* Partially working (see Current Issues)
* iPad 2 GSM (2,2)
 	* iOS 4.3.4
		* Fully working
	* iOS 4.3.5
		* Fully working
* iPad 2 CDMA (2,3)
 	* iOS 4.3.4
		* Fully working
	* iOS 4.3.5
		* Fully working 
* Tested on Mac OS 10.13-10.15


#  Instructions:

- Before starting, ensure your iPad is Jailbroken with a tfp0 exploit, and OpenSSH + Core Utilities + Core Utilities (/bin) installed.
- While conducting the process, keep your iPad plugged into your computer (obviously).
- Keep your root password as alpine throughout the process. 
- As always, if one of the scripts refuses to run (permission denied) just run chmod +x on it.
- Keep trying things, don't be dismayed. I recommend you start with iOS 4.3.5, and if that doesn't work, odds are your iPad isn't compatible.
- Don't come yelling at me if your iPad 2 is not compatible. Be smart, check sndeep.info if you're not certain. 

##  1. Restore and Jailbreak:
We need to get our iPad onto a modified version of iOS 6.1.3 with lwvm patched out and replaced with GPT.

1. First, build patched IPSW and grab blobs (of course, omit < > when entering). For model enter either 2,1 2,2 or 2,3. For option enter A. Option B is also included but will install iOS 4.3.3 (see Current Issues):

`./Create-Restore.sh <Model> <Option> `

2. Restore to IPSW (Enter root password, alpine, when asked. If the restore process doesn't start after e.g. fish: storing file 73728 (73728) just click your home button:		

`./Restore.sh <IP-Address>`

3. Set up your device.
4. A Jailbreak is prebuilt into the IPSW, but you wont see the Cydia app. To fix this run:

`./Cydia-Fix.sh <IP-Address>`	

5. Done, you should see Cydia on your Springboard, open it, and let it do it's thing. Once it's done, reboot your device (Cydia wont open if you don't). Open Cydia, upgrade essential. Do not do complete upgrade!

##  2. iOS 4 and the Second Partition:
Now, we'll partition our device, install iOS 4, and patch it. Once this is done, you'll be good to go!

1. First, we'll install necesary files, partition the device, and patch it. (It will ask for your root password a few times, as always, enter alpine. Again, If the  process doesn't continue after e.g. fish: storing file 73728 (73728) just click your home button):

`./Partition.sh <Model> <IP-Address>`

2. Lastly, we'll initalize our partition, build our filesystem, restore it, and patch it. For Version enter either 4.3.4 or 4.3.5 if you chose option A, or 4.3.3 if you chose option B. This step generally takes time, so just sit back and relax:	

`./iOS4.sh <Model> <Version> <IP-Address>`

3. That's it, your done, and your device will reboot. To boot into iOS 4, lauch the 4tify app. Once your screen goes black wait a sec, then tap your homebutton, and should see your device start to verbose boot within 10-15 seconds.

4. If you delete the 4tify app, or it doesn't seem to be working, you can always run:

`./Reinstall-App.sh <ip-address>`

****As of right now, modifying your iOS 4 password is dangerous, and will likely result in a recover loop. Until this is fixed, do not set it!***

## Current Issues
* ***4.3.3 and Below NAND WMR/FTL Error*** 
	* You'll notice that 4.3.3 is bundled with the project, this is to allow various other developers to take a shot at resolving this issue. I've been working with axi0mX for a few days on this so far no luck. Essentially, there's some WMR/FTL driver that apple modified between 4.3.3 and 4.3.4 that will result in an error when trying to boot into ios 4.3.3 and below. If you would like to take a shot at gettting this to work, you can view the error in iRecovery after you try to boot iOS 4.3.3. If you want to help work on this shoot me a dm. 
* ***iPad Wifi (2,1) Black Screen Issue***
	* I've deemed iPad 2,1 partially working for this reason. On some iPad 2,1s the device will boot iOS 4 no problem, but the screen will stay black with the backlight on. The device is fully responsive, you can unlock it, it plays sounds, yet the screen is black! Not sure the cause of this as of right now, and why it only plagues some iPad 2,1 models and not others.    
 


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
* @Tommymossss for entertaining me while I made this.
 
