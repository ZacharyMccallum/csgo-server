# [edit]csgo-server - zachary mccallum - 12/5/2021
Configurable CSGO server

Zachary McCallum
CSI 3660
Technology Used
Google Cloud Platform:
Cloud hosting platform that provides necessary hardware and software as a service to users. 
Instance Details:
name: csgo-server
instance id: 657742577793391306
Machine configuration:
Machine type: e2-medium
CPU platform: Intel Broadwell
Ubuntu 18.04 LTR
Linux Operating System version used during original configuration
SteamCMD
 Installation:
sudo apt-get install lib32gcc1
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