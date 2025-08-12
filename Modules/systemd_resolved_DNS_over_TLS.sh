systemd_resolved_DNS_over_TLS(){
	resolved_conf="/etc/systemd/resolved.conf.d/10-securedns.conf"
	[ -f "${resolved_conf}" ] && return
	print_info "Configuring systemd‑resolved for DNS‑over‑TLS..."
	apt install -y systemd
	tee "${resolved_conf}"  > /dev/null <<-EOF
	[Resolve]
	DNS=1.1.1.1 9.9.9.9
	DNSOverTLS=yes
	EOF
	systemctl restart systemd-resolved
	print_success "systemd_resolved_DNS_over_TLS completed..."
}
functions_list="$functions_list systemd_resolved_DNS_over_TLS"
