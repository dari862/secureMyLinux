Disabling_coredumps_globally(){
	[ -f "/etc/security/limits.d/60-disable-coredump.conf" ] && return
	print_info "Disabling coredumps globally"

	# Disable via systemd-coredump
	mkdir -p /etc/systemd/system.conf.d
	mkdir -p /etc/systemd/user.conf.d
	tee /etc/systemd/system.conf.d/60-disable-coredump.conf > /dev/null <<-EOF
	[Manager]
	DumpCore=no

	[Coredump]
	Storage=none
	ProcessSizeMax=0
	EOF

	tee /etc/systemd/user.conf.d/60-disable-coredump.conf > /dev/null <<-EOF
	[Manager]
	DumpCore=no

	[Coredump]
	Storage=none
	ProcessSizeMax=0
	EOF

	# Disable via limits.conf
	tee /etc/security/limits.d/60-disable-coredump.conf > /dev/null <<-EOF
	# Disable coredumps
	* hard core 0
	* soft core 0
	EOF

	# Disable via sysctl
	tee /etc/sysctl.d/99-disable-coredumps.conf > /dev/null <<-EOF
	fs.suid_dumpable = 0
	EOF
	sysctl -p /etc/sysctl.d/99-disable-coredumps.conf
	print_success "Coredumps disabled system-wide."
}
functions_list="$functions_list Disabling_coredumps_globally"
