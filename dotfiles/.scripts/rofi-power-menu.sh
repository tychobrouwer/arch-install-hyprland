#!/bin/sh

## Author  : Aditya Shakya (adi1090x)
## Github  : @adi1090x
#
## Applets : Power Menu

# Theme Elements
# prompt="`hostname`"
mesg="`uptime -p | sed -e 's/up //g'`"

list_col='1'
list_row='5'

# Options
option_1=" Lock"
option_2=" Logout"
option_3=" Suspend"
option_4=" Reboot"
option_5=" Shutdown"
yes=''
no=''

# Rofi CMD
rofi_cmd() {  
  rofi -theme-str "listview {columns: $list_col; lines: $list_row;}" \
    -dmenu \
    -p "$mesg" \
    -markup-rows \
    -theme $HOME/.config/rofi/power-menu/theme.rasi
}

# Pass variables to rofi dmenu
run_rofi() {
  echo -e "$option_1\n$option_2\n$option_3\n$option_4\n$option_5" | rofi_cmd
}

# Confirmation CMD
confirm_cmd() {
  rofi -theme-str 'window {location: center; anchor: center; fullscreen: false; width: 350px;}' \
    -theme-str 'mainbox {orientation: vertical; children: [ "message", "listview" ];}' \
    -theme-str 'listview {columns: 2; lines: 1;}' \
    -theme-str 'element-text {horizontal-align: 0.5;}' \
    -theme-str 'textbox {horizontal-align: 0.5;}' \
    -dmenu \
    -p 'Confirmation' \
    -mesg 'Are you Sure?' \
    -theme $HOME/.config/rofi/power-menu/theme-confirm.rasi
}

# Ask for confirmation
confirm_exit() {
  echo -e "$yes\n$no" | confirm_cmd
}

# Confirm and execute
confirm_run () {  
  selected="$(confirm_exit)"
  if [[ "$selected" == "$yes" ]]; then
        ${1} && ${2} && ${3}
    else
        exit
    fi
}

# Execute Command
run_cmd() {
  if [[ "$1" == '--opt1' ]]; then
    # swaylock --config $HOME/.config/swaylock/config
    hyprlock
  elif [[ "$1" == '--opt2' ]]; then
    confirm_run 'hyprctl dispatch exit'
  elif [[ "$1" == '--opt3' ]]; then
    confirm_run 'systemctl suspend'
  elif [[ "$1" == '--opt4' ]]; then
    confirm_run 'systemctl reboot'
  elif [[ "$1" == '--opt5' ]]; then
    confirm_run 'systemctl poweroff'
  fi
}

# Actions
chosen="$(run_rofi)"
case ${chosen} in
    $option_1)
    run_cmd --opt1
        ;;
    $option_2)
    run_cmd --opt2
        ;;
    $option_3)
    run_cmd --opt3
        ;;
    $option_4)
    run_cmd --opt4
        ;;
    $option_5)
    run_cmd --opt5
        ;;
esac

