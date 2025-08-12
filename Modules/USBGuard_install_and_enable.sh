USBGuard_install_and_enable(){
	[ -d "/var/log/usbguard" ] && return
	print_info "Installing and enabling USBGuard..."
	apt install -y usbguard
	systemctl enable --now usbguard
	mkdir -p /var/log/usbguard
	print_success "USBGuard_install_and_enable completed..."
}
functions_list="$functions_list USBGuard_install_and_enable"
