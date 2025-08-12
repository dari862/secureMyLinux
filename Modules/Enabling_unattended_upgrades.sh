Enabling_unattended_upgrades() {
	[ "$(systemctl is-enabled unattended-upgrades 2>/dev/null)" = "enabled" ] && return
	print_info "Installing security tools..."
	apt install -y unattended-upgrades

	print_info "Enabling unattended upgrades..."
	dpkg-reconfigure -f noninteractive unattended-upgrades
}
functions_list="$functions_list Enabling_unattended_upgrades"
