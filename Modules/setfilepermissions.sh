setfilepermissions(){
	chmod 440 /etc/sudoers.d/timeout
	# Make ld.so.preload readable only by root, so user processes can override
	# hardened_malloc by resetting LD_PRELOAD.
	chmod 600 /etc/ld.so.preload
	print_success "setfilepermissions completed"
}
functions_list="$functions_list setfilepermissions"
