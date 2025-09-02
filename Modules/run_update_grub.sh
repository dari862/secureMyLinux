run_update_grub(){
	[ "grub_update" = false ] && return
	
	print_info "Updating GRUB..."
	if [ -x /usr/sbin/update-grub ]; then
    	/usr/sbin/update-grub
	elif [ -x /sbin/grub2-mkconfig ]; then
    	/sbin/grub2-mkconfig -o /boot/grub2/grub.cfg
	else
    	print_warning "GRUB update command not found. Please update GRUB manually."
	fi
	
	print_success "GRUB Updated"
}
functions_list="$functions_list run_update_grub"
