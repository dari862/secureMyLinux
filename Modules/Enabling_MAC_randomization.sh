Enabling_MAC_randomization(){
	[ -f "/etc/NetworkManager/conf.d/100-mac-randomization.conf" ] && return
	print_info "Enabling MAC randomization with NetworkManager"
	print_info "MAC randomization can be stable (persisting the same random MAC per access point across disconnects/reboots),"
        print_info "or it can be randomized per-connection (every time it connects to the same access point it uses a new MAC)."
        ask_first "Do you want to use per-connection Wi-Fi MAC address randomization?" "[y/N]" "y|Y" && \
			( randomization_level=random && print_info "Selected state: per-connection" ) || ( randomization_level=stable && print_info "Selected state: per-network (stable)" )
	apt install -y network-manager

	# Create config to enforce MAC randomization for Wi-Fi
	mkdir -p /etc/NetworkManager/conf.d
	tee /etc/NetworkManager/conf.d/100-mac-randomization.conf > /dev/null <<-EOF
	[device]
	wifi.scan-rand-mac-address=yes

	[connection]
	wifi.cloned-mac-address=$randomization_level
	ethernet.cloned-mac-address=stable

	[main]
	rc-manager=symlink
	EOF

	# Ensure MAC is randomized at boot too (not stored in persistent rules)
	rm -f /etc/udev/rules.d/70-persistent-net.rules || true

	systemctl restart NetworkManager
	print_success "MAC randomization enabled for Wi-Fi and stable MACs for Ethernet."
}
functions_list="$functions_list Enabling_MAC_randomization"
