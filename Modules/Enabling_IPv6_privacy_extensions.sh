Enabling_IPv6_privacy_extensions(){
	[ -f "/etc/sysctl.d/99-ipv6-privacy.conf" ] && return
	print_info "Enabling IPv6 privacy extensions"

	tee /etc/sysctl.d/99-ipv6-privacy.conf  > /dev/null <<-EOF
	net.ipv6.conf.all.use_tempaddr = 2
	net.ipv6.conf.default.use_tempaddr = 2
	EOF
	sysctl -p /etc/sysctl.d/99-ipv6-privacy.conf

	print_success "IPv6 privacy extensions enabled."
}
functions_list="$functions_list Enabling_IPv6_privacy_extensions"
