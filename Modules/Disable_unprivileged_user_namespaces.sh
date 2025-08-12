Disable_unprivileged_user_namespaces(){
	[ -f "/etc/sysctl.d/99-unpriv_userns.conf" ] && return
	print_info "Disable unprivileged user namespaces, but allow sandbox apps"
	tee /etc/sysctl.d/99-unpriv_userns.conf  > /dev/null <<-EOF
	# preserve Flatpak, Trivalent & others requiring userns
	kernel.unprivileged_userns_clone=0
	EOF
	sysctl -p /etc/sysctl.d/99-unpriv_userns.conf
	# Allow on per-app basis: e.g.
	print_info "To enable userns for a given app, run:"
	print_info "  setcap cap_sys_admin+ep /usr/bin/bwrap  # for flatpak bubblewrap fallback if needed"
	print_success "Disable_unprivileged_user_namespaces completed..."
}
functions_list="$functions_list Disable_unprivileged_user_namespaces"
