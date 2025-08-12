enable_flatpak_autoupdate(){
	! command -v flatpak >/dev/null 2>&1 && return
	[ -f "/etc/systemd/system/flatpak-system-update.service" ] && return
	print_info "Creating system-wide flatpak update service and timer..."
	mkdir -p /etc/systemd/system

	tee /etc/systemd/system/flatpak-system-update.service >/dev/null <<-EOF
	[Unit]
	Description=Flatpak System Automatic Update
	Wants=network-online.target
	After=network-online.target

	[Service]
	Type=oneshot
	ExecStart=/bin/bash -c '/usr/bin/flatpak --system uninstall --unused -y --noninteractive; /usr/bin/flatpak --system update -y --noninteractive; /usr/bin/flatpak --system repair'
	EOF

	tee /etc/systemd/system/flatpak-system-update.timer >/dev/null <<-EOF
	[Unit]
	Description=Trigger Flatpak System Update

	[Timer]
	OnCalendar=*-*-* 04:00:00
	RandomizedDelaySec=10m
	Persistent=true

	[Install]
	WantedBy=timers.target
	EOF

	print_info "Reloading systemd daemon and enabling system timer..."
	systemctl daemon-reload
	systemctl enable --now flatpak-system-update.timer

	print_info "Creating user-level flatpak update service and timer..."

	mkdir -p /etc/systemd/user/
	tee /etc/systemd/user/flatpak-user-update.service >/dev/null <<-EOF
	[Unit]
	Description=Flatpak User Automatic Update
	Wants=network-online.target
	After=network-online.target

	[Service]
	Type=oneshot
	ExecStart=/bin/bash -c '/usr/bin/flatpak --user uninstall --unused -y --noninteractive; /usr/bin/flatpak --user update -y --noninteractive; /usr/bin/flatpak --user repair'
	EOF

	tee /etc/systemd/user/flatpak-user-update.timer >/dev/null <<-EOF
	[Unit]
	Description=Trigger Flatpak User Update

	[Timer]
	OnCalendar=*-*-* 04:00:00
	RandomizedDelaySec=10m
	Persistent=true

	[Install]
	WantedBy=timers.target
	EOF

	print_info "Reloading user systemd daemon and enabling user timer..."
	systemctl --user daemon-reload
	systemctl --user enable --now flatpak-user-update.timer

	print_info "To keep the user timer running after logout, enable lingering:"
	print_info "  loginctl enable-linger \$USER"

	print_success "Setup complete! System and user flatpak update timers are enabled."

}
functions_list="$functions_list enable_flatpak_autoupdate"
