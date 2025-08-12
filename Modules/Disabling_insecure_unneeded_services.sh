Disabling_insecure_unneeded_services(){
	[ -f "/usr/lib/systemd/system/avahi-daemon.socket.d/override.conf" ] && return
	print_info "Disabling print services"
	systemctl disable cups.socket
	systemctl mask cups.socket
	systemctl disable cups.service
	systemctl mask cups.service

	systemctl disable cups-browsed
	systemctl mask cups-browsed

	print_info "Disabling sshd"
	systemctl disable sshd
	systemctl mask sshd

	print_info "Disabling avahi-daemon"
	systemctl disable avahi-daemon.socket
	systemctl mask avahi-daemon.socket
	systemctl disable avahi-daemon.service
	systemctl mask avahi-daemon.service
	tee /usr/lib/systemd/system/avahi-daemon.service.d/override.conf >/dev/null <<-EOF
	[Unit]
	StopWhenUnneeded=true
	EOF
	tee /usr/lib/systemd/system/avahi-daemon.socket.d/override.conf >/dev/null <<-EOF
	[Unit]
	StopWhenUnneeded=true
	EOF
	print_info "Disabling the alsa state daemon"
	systemctl disable alsa-state
	systemctl mask alsa-state

	print_info "Disabling the modem manager"
	systemctl disable ModemManager
	systemctl mask ModemManager

	print_info "Disabling NFS daemons"
	systemctl disable nfs-idmapd
	systemctl mask nfs-idmapd

	systemctl disable nfs-mountd
	systemctl mask nfs-mountd

	systemctl disable nfsdcld
	systemctl mask nfsdcld

	systemctl disable rpc-gssd
	systemctl mask rpc-gssd

	systemctl disable rpc-statd-notify
	systemctl mask rpc-statd-notify

	systemctl disable rpc-statd
	systemctl mask rpc-statd

	systemctl disable rpcbind
	systemctl mask rpcbind

	systemctl disable gssproxy
	systemctl mask gssproxy

	print_info "Disabling the sssd daemons"
	systemctl disable sssd
	systemctl mask sssd

	systemctl disable sssd-kcm
	systemctl mask sssd-kcm

	print_info "disable unconfined rootful services"
	systemctl disable uresourced.service
	systemctl mask uresourced.service

	systemctl disable low-memory-monitor.service
	systemctl mask low-memory-monitor.service

	systemctl disable thermald.service
	systemctl mask thermald.service

	print_info "Disabling insecure/unneeded services"

	SERVICES=(
  	cups
  	geoclue
  	avahi-daemon
  	bluetooth
  	ModemManager
  	snapd
  	systemd-resolved
  	systemd-timesyncd
  	passim
  	thermald
	)

	for svc in "${SERVICES[@]}"; do
  	if systemctl list-units --full -all | grep -q "$svc"; then
    	systemctl disable --now "$svc" || true
    	systemctl mask "$svc" || true
    	print_info "Disabled and masked: $svc"
  	fi
	done

	print_success "Insecure and unused services disabled."
}
functions_list="$functions_list Disabling_insecure_unneeded_services"
