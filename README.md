# Panther X Dashboard #

This is the Dashboard for Panther X Miner, it can support Panther X1 and Panther X2. it was forked from briffy's repository. but It was enhanced by some new features.

* Pull the update package directly through GitHub repo without the need for a separate tar package 
* Support Panther X1 and Panther X2 at the same time
* Support Panther X firmware version display

## Initialization ##

1. Find the internal IP address of your Panther miner.
2. Log in at https://__YOURIP__
  - Username: admin
  - Password: admin
3. Click "Tools"
4. Click "Reset Password"
5. Enter a secure password and click submit.
6. You can login SSH and Dashboard with admin user and the password your set
7. Enjoy!

## Installation & Upgrade Instructions ##

1. Connect via SSH to your miner (either using PuTTY or open cmd and type:  ssh admin@YOURIP)
2. Enter the admin username and the password you set.
3. Type the following command: wget https://raw.githubusercontent.com/Panther-X/PantherDashboard/main/install.sh -O - | sudo bash

Note: For hackers, You can also install custom version by add the following file before step 3

e.g. Install 0.2.16

```bash
echo main > /var/dashboard/branch
echo 1193f56 > /var/dashboard/commit-hash
```

## Removal Instructions ##

1. Connect via SSH to your miner (either using PuTTY or open cmd and type:  ssh admin@YOURIP)
2. Enter the admin username and the password you set.
3. Type the following command: sudo bash /var/dashboard/uninstall.sh

## Caveats ##

* If you click a button to enable/disable a service, manually refresh a few times until it updates.
* You will likely get a "This site is not secure" banner when you first connect.  This is because I've enabled HTTPS by default with a self-signed certificate.  The reason it is "not secure" is because web browsers prefer certificates to be signed by an authority, not just yourself.  I promise though, HTTPS with a self-signed certificate is way more secure than standard HTTP (don't take my word for it, Google "https vs http") because at least your data is being encrypted this way.  If you care enough, go buy a certificate for a couple of bucks and add it into /etc/ssl/  (you've got root access now).

## Change Log ##

- 0.2.18
1. Add Helium Miner Log Analyzer
2. Fix miner verison check with quay.io server

- 0.2.17
1. Fix miner version check
2. Update the server for miner version check

- 0.2.16

1. Fix miner upgrade failed after the first installation
2. Fix disk usage for Panther X2
3. Clean peer book when clearing blockchain data

- 0.2.15

1. Update color for service enable
2. Fix clear blockchain failed after a sudden power failure
3. Fix update miner failed after a sudden power failure
4. Fix update dashboard failed after a sudden power failure

- 0.2.14

1. Fix fastsync flag keep spinning after sync is completed
2. Don't need to backup docker config right now
3. Disable connmon DNS proxy
4. Show SN in the footer, Only Panther X2 (except CN470) support
5. Fix wrong URL for miner and dashboard update

- 0.2.13

1. Fix the issue that dashboard on some machine could not be opened due to certificate exception.
2. Add a password reset prompt, it needs to input at least 6 digits.
3. Fix the issue that it always update failed when click update miner on some panthers.
4. Fix the issue that miner stopped running suddenly on some panthers.
5. Fix the issue that bluetooth cannot be turn on after it running for a long time on some panthers.

## Contribute ##
If you find some issues or problems when you use the dahsboard. you are always welcome to submit the issue here: https://github.com/Panther-X/PantherDashboard/issues

