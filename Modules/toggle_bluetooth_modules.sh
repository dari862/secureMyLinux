toggle_bluetooth_modules(){
	toggle_bluetooth_modules_path="${bin_path}/toggle_bluetooth_modules"
	[ -f "$toggle_bluetooth_modules_path" ] && return
	tee "$toggle_bluetooth_modules_path" >/dev/null <<-EOF
	#!/bin/bash
	# Toggle bluetooth kernel modules on/off (requires reboot)
	if [ "${EUID:-$(id -u)}" -ne 0 ]; then
  		printf "Please run as root"
  		exit 1
	fi
	BLUE_MOD_FILE="/etc/modprobe.d/99-bluetooth.conf"
	if test -e $BLUE_MOD_FILE; then
		rm -f $BLUE_MOD_FILE
		echo "Bluetooth kernel modules disabled. Reboot to take effect."
	else
		tee "$BLUE_MOD_FILE" >/dev/null <<-EOF2
			install bluetooth /sbin/modprobe --ignore-install bluetooth
			install btusb /sbin/modprobe --ignore-install btusb
		EOF2
		chmod 644 $BLUE_MOD_FILE
		echo "Bluetooth kernel modules enabled. Reboot to take effect."
	fi
	EOF
	chmod +x /usr/bin/toggle_bluetooth_modules
	print_success "script toggle_bluetooth_modules created."
}

functions_list="$functions_list toggle_bluetooth_modules"
