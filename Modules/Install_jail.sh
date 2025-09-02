Install_jail(){
	if ! command -v firejail &> /dev/null; then
		print_info "Installing firejail..."
  		apt-get install firejail
  		print_success "firejail installed..."
	fi
	# Configure Firejail
	firecfg
	
	# Create custom profile for browsers
	mkdir -p /etc/firejail
	tee /etc/firejail/browser-common.local >/dev/null 2>&1 <<-EOF
	# Custom browser security profile
	caps.drop all
	netfilter
	noroot
	protocol unix,inet,inet6,netlink
	seccomp
	shell none
	nogroups
	nonewprivs
	
	private-cache
	private-dev
	private-tmp
	private-home=.mozilla,.config,.cache,Downloads
	
	disable-mnt
	noexec /tmp
	EOF
	
	for browser in firefox-esr firefox brave-browser;do
	sudo tee /etc/firejail/${browser}2.profile >/dev/null 2>&1 <<-EOF
	include /etc/firejail/browser-common.local
	
	# Firefox-specific rules (optional)
	private-bin ${browser}
	EOF
	done
}
functions_list="$functions_list Install_jail"
