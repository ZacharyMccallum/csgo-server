                                               
Zachary McCallum
CSI 3660

Note: configurations changed include [edit] tag, including user and date.

Technology Used
Github
Used for code versioning, and project files storage
Repo found here: https://github.com/ZacharyMccallum/csgo-server
Google Cloud Platform:


Cloud hosting platform that provides necessary hardware and software as a service to users. 
Instance Details:
name: csgo-server
instance id: 657742577793391306
Machine configuration:
Machine type: e2-medium
CPU platform: Intel Broadwell
Ubuntu 18.04 LTS
Linux Operating System version used during original configuration
Apache2
Used as webe service handler for hosting html pages.
SteamCMD
 Installation:
sudo apt-get install lib32gcc1
Counter-Strike: Global Offensive
Environment to be emulated as a server instance
Required Materials
- Steam Game Server Management Tool -
https://steamcommunity.com/dev/managegameservers
This tool helps to create a dedicated game server account, which addresses the anonymous login vulnerability that existed upon initial configuration.
- Instructional runthrough -
https://stechalon.com/how-to-create-your-own-csgo-counter-strike-global-offensive-dedicated-custom-server-ubuntu-centos#run-csgo-on-server
This reference is used for the general setup and configuration of Ubuntu 18.04
Note - this hyperlink seems to fail upon clicking in the GCP console, please copy and paste into browser.
- Ports to open at firewall -
https://linustechtips.com/topic/722940-what-ports-to-forward-for-a-csgo-server/
- Ubuntu 18.04 full guide -
https://www.reddit.com/r/GlobalOffensive/comments/iwm0i9/how_to_create_a_free_csgo_server_using_google/
While troubleshooting connectivity issues, I began comparing configurations that were present in 1, but not the other. Here is where it was discovered that improper firewall rules had been set for the GCP instance initially. 
- Steam server configs guide -
https://developer.valvesoftware.com/wiki/Counter-Strike:_Global_Offensive_Dedicated_Servers#autoexec.cfg
This reference was used for configuration of sv_* variables following server creation
- Configure Apache for Ubuntu -
https://phoenixnap.com/kb/how-to-install-apache-web-server-on-ubuntu-18-04
This reference is helpful for the installation of, and configuration of apache web services
- Install shelljs and use - 
https://stackoverflow.com/questions/44647778/how-to-run-shell-script-file-using-nodejs
This reference outlines how to install shelljs and use it within a javascript file to execute shell commands from web requests.
Install git on ubuntu 18.04
https://www.digitalocean.com/community/tutorials/how-to-install-git-on-ubuntu-18-04
This reference outlines the steps needed to install git
- Install SourceMod on Server - 
https://wiki.alliedmods.net/Installing_SourceMod
This will handle all custom mod installs and provide framework for mod creation.
Service Implementation:
Google Cloud Platform
Create an instance with the minimum requirements:
2GB RAM
40GB Disk Space
Note: For this example runthrough - ec2-medium was used for hardware configuration setup


Equivalent Command Line: gcloud compute instances create csgo-3660 --project=inbound-acolyte-326923 --zone=us-central1-a --machine-type=e2-medium --network-interface=network-tier=PREMIUM,subnet=default --maintenance-policy=MIGRATE --service-account=851841175058-compute@developer.gserviceaccount.com --scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/trace.append --tags=http-server,https-server --create-disk=auto-delete=yes,boot=yes,device-name=csgo-3660,image=projects/ubuntu-os-cloud/global/images/ubuntu-1804-bionic-v20211115,mode=rw,size=50,type=projects/inbound-acolyte-326923/zones/us-central1-a/diskTypes/pd-balanced --no-shielded-secure-boot --shielded-vtpm --shielded-integrity-monitoring --reservation-affinity=any


Setup CS:GO Environment In Ubuntu 18.04 Server
Upon instance creation completion, SSH into the Google Cloud Platform Instance via built-in service

Step 1: Perform System Updates
$sudo apt-get update && sudo apt-get upgrade

Step 2: Install library package for SteamCMD
sudo apt-get install lib32gcc1
Step 3: Create a seperate user “steam” for running CS:GO.
sudo useradd -m steam
To validate the creation of steam - check the output of cat /etc/passwd

Create UNIX password for ‘steam’

Switch user to “steam”
su - steam
Step 4: Create an installation path directory where we download SteamCMD.
mkdir ~/Steam && cd ~/Steam
Downloading and Installing SteamCMD
Step 1: Download the latest version of SteamCMD.
wget https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz

Step 2: Extract the downloaded file.
tar xf steamcmd_linux.tar.gz

Step 3: Run SteamCMD script file
./steamcmd.sh
This file will download the update from steam
After that, the updated steam will provide you the cmd prompt as shown below.
Steam>
Step 4: Set your CS:GO dedicated server install directory.
force_install_dir ./cs_go/
Step 5: Login using an anonymous steam account here.
Steam> login anonymous

Step 6: Finally, download and install CS:GO on the server.
app_update 740 validate
Note: This process will take an extended period of time to complete ~45 minutes for download, and another 
You will see “Success! App ‘740’ fully installed” as below. 
Allow Access on Server’s TCP and UDP Ports
In order to connect the game server, TCP and UDP ports should be allowed to all the players from the server. 
Configuring the firewall to allow connections to the server
 
Select "Firewall" on the left-hand side
Click "create firewall rule" at the top
Name your firewall rule
For "Targets", select "All instances in the network" (provided you don't have any other servers)
For "Source IP ranges", enter 0.0.0.0/0 to allow any IP addresses to connect
Check "tcp", and enter 27015-27030,27036-27037
Check "udp", and enter 4380,27000-27031,27036

Register CS:GO Game Auth Token ID
In order to run the game you need your steam token ID. Without a token ID, you won’t be able to host a game.
Your steam account should be qualified for generating token ID. Check here for the requirements and get your token ID.
Follow below picture to generate your auth token ID. 

Note: The appID 740 is the registered ID for Counter-Strike: Global Offensive dedicated server whereas appID 730 is the official game ID.
You will generate a token ID similar to this X38F6E71A3B8G6FE08354AF5BE078.
Run CS:GO On Server
There are specific commands to run different game modes. This means you have to enter different commands to run Causal, Competitive, and Deathmatch Mode. Below is an example of a command to run a casual match on de_dust2.
Important: You should be inside the cs_go directory before you run the command.
./srcds_run -game csgo -console -usercon + game_type 0 + game_mode 0 + mapgroup mg_active + map de_dust2 + sv_setsteamaccount [token_here] THISGSLTHERE -net_port_try
For different modes, you need to change the game_mode value.
Casual = game_mode 0
Competitive = game_mode 1
Deathmatch = game_mode 2
 
Replace “[token_here]” in the below command and enter.
Configure autoexec.cfg
In order to allow public users to acces the server, an autoexec.cfg file must be created and updated.

Path to autoexec.cfg - 
Configuration used for this Project
hostname "CS:GO Server - CSI3660"
sv_setsteamaccount 78B07BAA206BCAA92927545EE2684564
sv_minupdaterate 128
sv_mincmdrate 128
log on //This is set to turn on logging! Don't put this in your server.cfg
rcon_password "yourrconpassword"
sv_password "" //Only set this if you intend to have a private server!
sv_cheats 0 //This should always be set, so you know it's not on
sv_lan 0 //This should always be set, so you know it's not on
exec banned_user.cfg
exec banned_ip.cfg


Note: If you cannot connect right away, please be patient! It takes some time to set up the server fully to be ready for action.
CASUAL GAME MODE
./srcds_run -game csgo -console -usercon + game_type 0 + game_mode 0 + mapgroup mg_active + map de_dust2 + sv_setsteamaccount [token_here] THISGSLTHERE -net_port_try
COMPETITIVE GAME MODE
./srcds_run -game csgo -console -usercon + game_type 0 + game_mode 1 + mapgroup mg_active + map de_dust2 + sv_setsteamaccount [token_here] THISGSLTHERE -net_port_try
DEATHMATCH GAME MODE
./srcds_run -game csgo -console -usercon + game_type 1 + game_mode 2 + mapgroup mg_allclassic + map de_dust + sv_setsteamaccount [token_here] THISGSLTHERE -net_port_try
You will see the public IP of your game server after entering the above command. 
Join CS:GO Server
Launch steam application and open CS:GO. There are two ways you can join the game server.
First, connect through the game console. For that enable the developer console. 
Get back to the dashboard and open the console using “~” keyword and type “connect < your-ip-address >”. 
Second, adding server IP to your favorite list. For that, go to the Community Server Browser.
Click on the favourite tab. 
Add your server IP and connect it. 
Run CS:GO In Server’s Background
Your game will be disconnected or stopped when you log out from the server.
It is not possible to host the game staying logged in 24x7 on the server. So, we will host the game in a background session. By doing so, your game won’t stop until your server gets turned off.
For that, we will install a screen application on the server.
Install Screen In Ubuntu
sudo apt-get install screen -y
Install Screen In CentOS
sudo yum install screen -y
After installation, create a new session named “csgo” by typing:
screen -R csgo
Now run the game host command. In my case, I am running competitive game mode.
./srcds_run -game csgo -console -usercon + game_type 0 + game_mode 1 + mapgroup mg_active + map de_dust2 + sv_setsteamaccount [token_here] THISGSLTHERE -net_port_try
When the game is hosted successfully, exit from that screen(detach) by pressing the keys at the same time.
Crtl + a + d
Now you are out of that session. To see the running background session type
screen -ls
You will get the output like this:
There is a screen on:
    7166.csgo    (Detached)
1 Socket in /run/screen/S-stechalon.
7166 is the ID and csgo is the name of the screen.
To rejoin the detached screen type:
screen -r 7166
 
Install Web Services
Before installing new software, it’s a good idea to refresh your local software package database to make sure you are accessing the latest versions. This helps cut down on the time it takes to update after installation, and it also helps prevent zero-day exploits against outdated software.
 
Open a terminal and type:
sudo apt-get update
Let the package manager finish updating.
 
Step 1: Install Apache
To install the Apache package on Ubuntu, use the command:
sudo apt-get install apache2
The system prompts for confirmation – do so, and allow the system to complete the installation.

Start Apache:
sudo systemctl start apache2.service
 

Backup Strategy
Backups are automatically set up to run at 2 am on the first day of a new month. The backup contents are shown below
Contents of:
sudo crontab -e
* 2 0 * * /root/backup.sh >/dev/null 2>&1

Shell script to backup - Auto
#!/bin/bash
####################################
#
# Backup to NFS mount script.
#
####################################
# What to backup. 
backup_files="/home/steam/Steam /etc /root /boot /var/www/html"
# Where to backup to.
dest="/mnt/backup"
# Create archive filename.
day=$(date +%A)
hostname=$(hostname -s)
archive_file="$hostname-$day.tgz"
# Print start status message.
echo "Backing up $backup_files to $dest/$archive_file"
date
echo
# Backup the files using tar.
tar czf $dest/$archive_file $backup_files
# Print end status message.
echo
echo "Backup finished"
date
# Long listing of files in $dest to check file sizes.
ls -lh $dest
#[edit] script created - zachary mccallum - 12/5/2021
#main reference for backup script:https://ubuntu.com/server/docs/backups-shell-scripts

