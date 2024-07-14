#!/usr/bin/env bash

# Get a list of available wifi connections and morph it into a nice-looking list
wifi_list=$(nmcli --fields "SECURITY,SSID" device wifi list | sed 1d | sed 's/  */ /g' | sed -E "s/WPA*.?\S/ /g" | sed "s/^--/ /g" | sed "s/  //g" | sed "/--/d")

connected_network=$(iw dev wlan0 info | sed -n 's/ssid//p' | awk '{$1=$1};1')
connected_network_line=$(echo $wifi_list | awk "/$connected_network/{print NR}")

connected=$(nmcli -fields WIFI g)
if [[ "$connected" =~ "enabled" ]]; then
	toggle="  Disable Wi-Fi"
	wifi_list="$wifi_list\n"
elif [[ "$connected" =~ "disabled" ]]; then
	toggle="  Enable Wi-Fi"
	connected_network="Disconnected"
fi

settings=" Settings"

# Use rofi to select wifi network
chosen_network=$(echo -e "$toggle\n$wifi_list$settings" | uniq -u | rofi -dmenu -i -p "$connected_network" -selected-row $connected_network_line -theme $HOME/.config/rofi/wifi-menu/theme.rasi)

# Get name of connection
read -r chosen_id <<< "${chosen_network:3}"

if iw dev wlan0 info; then
	exit
elif [ "$chosen_network" = "" ]; then
	exit
elif [ "$chosen_network" = " Settings" ]; then
	nm-connection-editor
elif [ "$chosen_network" = "  Enable Wi-Fi" ]; then
	nmcli radio wifi on
elif [ "$chosen_network" = "  Disable Wi-Fi" ]; then
	nmcli radio wifi off
else
	# Message to show when connection is activated successfully
  success_message="You are now connected to the Wi-Fi network \"$chosen_id\"."

	# Get saved connections
	saved_connections=$(nmcli -g NAME connection)

	if [[ $(echo "$saved_connections" | grep -w "$chosen_id") = "$chosen_id" ]]; then
		nmcli connection up id "$chosen_id" | grep "successfully" && notify-send "Connection Established" "$success_message"
	else
		if [[ "$chosen_network" =~ "" ]]; then
			wifi_password=$(rofi -dmenu -click-to-exit -p "Password:" -theme $HOME/.config/rofi/wifi-menu/theme-password.rasi)
		fi

		nmcli device wifi connect "$chosen_id" password "$wifi_password" | grep "successfully" && notify-send "Connection Established" "$success_message"
  fi
fi
