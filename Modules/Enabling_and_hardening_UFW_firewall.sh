Enabling_and_hardening_UFW_firewall(){
	[ "$(sudo ufw status | grep Status | awk '{print $2}')" == "active" ] && return
	print_info "Enabling and hardening UFW firewall"
	apt install -y ufw
	ufw default deny incoming
	ufw default deny outgoing
	ufw allow out 53
	ufw allow out 123
	ufw disable
	ufw enable
	print_success "UFW is enabled with all ports closed by default."
}
functions_list="$functions_list Enabling_and_hardening_UFW_firewall"
