removedkmshelper(){
	[ ! -f "/usr/libexec/gnome-software-dkms-helper" ] && return
	rm -f /usr/libexec/gnome-software-dkms-helper
	print_success "removedkmshelper completed"
}
functions_list="$functions_list removedkmshelper"
