#DENNIS - Dynamic ENdpoint Network Interface Switchover

##Some Background

This project started with a very specific use case in mind

As the name suggests, it monitors two network interfaces. If the primary iface goes down, the secondary iface gets its IP changed and NetworkManager is restarted.

Yes, it is over-engineered and it is a stupid solution to a simple problem of having terrible WiFi adapters.
Yes, I added **ENpoint** to the acronym so it spells out Dennis.

Also uses Telegram for alerts.

##Use Case
I have a primary IP address which I require a guaranteed level of availability. This script is able to check the status of the interface with the primary IP - and when it finds out that it is down, it assigns the IP to another interface and restarts NetworkManager

*It works with NetworkManager only.*

##Config Files
The folder **sample_conf** contains sample configuration files. 
Simply rename it to **conf** and put in the relevant infos to start

Here's a list of info that you will need:
- Name of Primary Interface
- Name of Secondary Interface
- Static IP of Primary Interface
- Static IP of Secondary Interface
- Telegram bot API token
- Chat ID of the Telegram Group to receive alerts

Here's what you need to change in the config files:

#####conf/current_status
- Name of Primary Interface
- Name of Secondary Interface

#####conf/DENNIS.conf
- Name of Primary Interface
- Name of Secondary Interface
- Static IP of Primary Interface
- Static IP of Secondary Interface

#####conf/telg_token
- Telegram bot API token

#####conf/telg_chatid
- Chat ID of the Telegram Group to receive alerts

#####nmconnection files
Last but not least, you will also need to provide your nmconnection files, which contains the NetworkManager connection profile - two samples have been provided under sample_conf/ directory
Do remember to name them primary.nmconnection and secondary.nmconnection!
