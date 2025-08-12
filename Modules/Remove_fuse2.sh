Remove_fuse2(){
	if command -v fuse2 >/dev/null; then
		print_info "Remove suid fuse2 if unmaintained"
  		apt purge -y fuse2
		print_success "Remove_fuse2 completed..."
	fi
}
functions_list="$functions_list Remove_fuse2"
