#!/bin/bash

source conf/DENNIS.conf

pri_if=$CFG_PRIMARY_IFACE # Primary Interface
sec_if=$CFG_SECONDARY_IFACE # Secondary (fallback) Interface

pri_if_ip=$CFG_PRIMARY_IP # Primary Interface IP
sec_if_ip=$CFG_SECONDARY_IP # Secondary (fallback) Interface IP

log() {
	msg=$1
	echo -e $(date): $msg >> network_status.log
}

log_down () {	# if Network Adapter is down
	timenow=$(date)
	if_name=$1
	if_ip=$2

	# Log downtime
	echo -e $timenow ": \e[41mERROR\e[0m : $if_name ($if_ip) is down!" >> network_status.log
	
	# Send an alert via Telegram
	./telg_bot.py "DOWN:$timenow:WiFi adapter $if_name ($if_ip) is down."
}

read_status () {
	source conf/current_status
}

write_status () {
	for i in "${!current_@}"; do
		printf '%s=%q\n' "$i" "${!i}"
	done > conf/current_status

	read_status
}

is_interface_down () {
	if_ip=$1

	ifconfig_output=$(ifconfig | grep $if_ip)

	if [ -z "$ifconfig_output" ]; then
		return 0 # indicates the interface is down
	else
		return 1 # indicates the interface is up
	fi
}

change_NM_conf () {
	# This function replaces the system-connections conf file in NetworkManager
	cp conf/primary.nmconnection /etc/NetworkManager/system-connections/primary.nmconnection
	cp conf/secondary.nmconnection /etc/NetworkManager/system-connections/secondary.nmconnection
	
	log "Replaced NetworkManager Config Files. Restarting NetworkManager Service now..."
	
	systemctl restart NetworkManager.service			

	svc_status=$(systemctl status NetworkManager.service)
	svc_status_value=$(echo $svc_status | grep "active (running)" | wc -l)

	if [ $svc_status_value -ge 1 ]; then
		log "\e[32;1m[i]\e[0m NetworkManager service started successfully."
	else
		log "\e[31;1m[X]\e[0m NetworkManager service failed to start."
	fi
}

echo DENNIS_main.sh starting ... > network_status.log

while [ 1 -eq 1 ]; do
	
	read_status

	if $current_fallback_mode; then
		log "Currently in Fallback Mode. Checking both Interfaces availability..."

		if is_interface_down $pri_if_ip; then
			log "Both Interfaces are down - GG"
		else
			log "Primary Interface is well. Checking status of Secondary Interface..."
		fi
		
		if is_interface_down $sec_if_ip; then
			log "\e[31;1m[X]\e[0m Secondary Interface failed to start."
		else
			log "\e[1;32;5m[!]\e[0m Secondary Interface is alive - ready to exit fallback mode"
			
			# Revert changes made
			# Revert Config Files
			current_pri=$pri_if
			current_sec=$sec_if	
			sed -i "s/$sec_if/$current_pri/" conf/primary.nmconnection
			sed -i "s/$pri_if/$current_sec/" conf/secondary.nmconnection
			
			# Exit Fallback Mode
			current_fallback_mode=false
			write_status

			# Replace NetworkManager Config Files and Restart Service
			change_NM_conf
		fi
	else
		if is_interface_down $pri_if_ip; then
			
			# Create log that the primary interface is down
			log_down $pri_if $pri_if_ip
		
			# Check whether DR interface is still alive	
			if is_interface_down $sec_if_ip; then
				log down $sec_if $sec_if_ip
			else
				log "\e[1;33;5m[!]\e[0m Activating Secondary WiFi Interface ..."
				read_status

				# Activating Fallback Mode
				current_fallback_mode=true
				
				# Editing NMConnection Config Files
				current_pri=$sec_if
				current_sec=$pri_if
				sed -i "s/$pri_if/$current_pri/" conf/primary.nmconnection
				sed -i "s/$sec_if/$current_sec/" conf/secondary.nmconnection
				
				# Replace NetworkManager Config Files and Restart Service
				change_NM_conf
				
				write_status

				log "Fallback mode set to <$current_fallback_mode>"
				log "Primary interface changed to $current_pri"
			fi
		else
			log "Everything is well."
		fi
	fi	
	
	sleep 600

done
