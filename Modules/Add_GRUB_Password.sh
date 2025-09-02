Add_GRUB_Password(){
	[ -d "/var/log/usbguard" ] && return
	print_info "Adding password to GRUB ..."
	
	sread grub_pass "Enter GRUB password: "
	echo
	sread grub_pass2 "Confirm GRUB password: "
	echo
	
	[ "$grub_pass" != "$grub_pass2" ] && print_error "Passwords do not match. Exiting."
	grub_hash=$(printf '%s\n%s' "$grub_pass" "$grub_pass" | grub-mkpasswd-pbkdf2 | grep "grub.pbkdf2" | awk '{print $7}')
	[ -z "$grub_hash" ] && print_error "Failed to generate GRUB password hash."
	sread GRUB_USER "Enter username: "
	echo
	[ -z "$GRUB_USER" ] && GRUB_USER=admin
	custom_file="/etc/grub.d/40_grub_pass"
	
	if ! grep -q "set superusers=" "$custom_file"; then
    	print_info "Adding superuser ($GRUB_USER) configuration to $custom_file"
    	cat <<-EOF >> "$custom_file"
		set superusers="$GRUB_USER"
		password_pbkdf2 $GRUB_USER $grub_hash
		EOF
	else
    	print_success "Superuser already configured in $custom_file. Skipping edit."
	fi
	
	chmod 600 "$custom_file"
	grub_update=true
	
	print_success "Done. GRUB need to be updated to set password for user \"$GRUB_USER\"."
}
functions_list="$functions_list Add_GRUB_Password"
