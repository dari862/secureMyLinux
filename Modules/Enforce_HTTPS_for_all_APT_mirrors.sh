Enforce_HTTPS_for_all_APT_mirrors(){
	grep -q "http:" /etc/apt/sources.list || return
	print_info "Enforce HTTPS for all APT mirrors"
	sed -i 's|http://deb.|https://deb.|g' /etc/apt/sources.list
	sed -i 's|http://security.|https://security.|g' /etc/apt/sources.list
	apt update
	print_success "APT now uses HTTPS-only mirrors."
}
functions_list="$functions_list Enforce_HTTPS_for_all_APT_mirrors"
