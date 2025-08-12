enable_apparmor(){
	[ "$(systemctl is-enabled apparmor 2>/dev/null)" = "enabled" ] && return
	print_info "Updating system and installing required packages..."
	apt install -y apparmor apparmor-utils apparmor-profiles apparmor-profiles-extra

	print_info "Enabling AppArmor..."
	systemctl enable apparmor
	systemctl start apparmor

	print_info "Loading all AppArmor profiles..."
	aa-enforce /etc/apparmor.d/* || true
	print_success "hardening_using_apparmor completed"
}

functions_list="$functions_list enable_apparmor"
