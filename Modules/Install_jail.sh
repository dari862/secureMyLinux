Install_jail(){
	if ! command -v firejail &> /dev/null; then
		print_info "Installing firejail..."
  		apt install firejail
  		print_success "firejail installed..."
	fi
}
functions_list="$functions_list Install_jail"
