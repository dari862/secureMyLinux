Initializing_AIDE(){
	print_info "Initializing AIDE..."
	[ -f "/var/lib/aide/aide.db" ] && return
	apt install -y aide aide-common
	aideinit
	cp /var/lib/aide/aide.db.new /var/lib/aide/aide.db
}
functions_list="$functions_list Initializing_AIDE"
