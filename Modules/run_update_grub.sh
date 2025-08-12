run_update_grub(){
	[ "grub_update" = false ] && return
	print_info "Updating GRUB..."
	update-grub
	print_success "GRUB Updated"
}
functions_list="$functions_list run_update_grub"
