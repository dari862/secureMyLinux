enabling_authselect(){
	authselect current | grep -q 'with-faillock' && return
	print_info "Enabling faillock in PAM authentication profile"
	authselect enable-feature with-faillock 1> /dev/null
	print_success "enabling_authselect completed"
}
functions_list="$functions_list enabling_authselect"
