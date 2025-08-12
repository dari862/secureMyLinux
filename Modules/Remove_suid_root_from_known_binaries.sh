Remove_suid_root_from_known_binaries(){
	print_info "Remove suid-root from known binaries"
	whitelist=(
    	"/usr/bin/nvidia-modprobe"
    	"/usr/lib/polkit-1/polkit-agent-helper-1"
    	"/usr/lib64/libhardened_malloc-light.so"
    	"/usr/lib64/libhardened_malloc-pkey.so"
    	"/usr/lib64/libhardened_malloc.so"
    	"/usr/lib64/glibc-hwcaps/x86-64/libhardened_malloc-light.so"
    	"/usr/lib64/glibc-hwcaps/x86-64/libhardened_malloc-pkey.so"
    	"/usr/lib64/glibc-hwcaps/x86-64/libhardened_malloc.so"
    	"/usr/lib64/glibc-hwcaps/x86-64-v2/libhardened_malloc-light.so"
    	"/usr/lib64/glibc-hwcaps/x86-64-v2/libhardened_malloc-pkey.so"
    	"/usr/lib64/glibc-hwcaps/x86-64-v2/libhardened_malloc.so"
    	"/usr/lib64/glibc-hwcaps/x86-64-v3/libhardened_malloc-light.so"
    	"/usr/lib64/glibc-hwcaps/x86-64-v3/libhardened_malloc-pkey.so"
    	"/usr/lib64/glibc-hwcaps/x86-64-v3/libhardened_malloc.so"
    	"/usr/lib64/glibc-hwcaps/x86-64-v4/libhardened_malloc-light.so"
    	"/usr/lib64/glibc-hwcaps/x86-64-v4/libhardened_malloc-pkey.so"
    	"/usr/lib64/glibc-hwcaps/x86-64-v4/libhardened_malloc.so"
	)


	is_in_whitelist() {
    	local binary="$1"
    	for allowed_binary in "${whitelist[@]}"; do
        	if [ "$binary" = "$allowed_binary" ]; then
            	return 0
        	fi
    	done
    	return 1
	}

	find /usr -type f -perm /4000 |
    	while IFS= read -r binary; do
        	if ! is_in_whitelist "$binary"; then
            	print_info "Removing SUID bit from $binary"
            	chmod u-s "$binary"
            	print_info "Removed SUID bit from $binary"
        	fi
    	done

	find /usr -type f -perm /2000 |
    	while IFS= read -r binary; do
        	if ! is_in_whitelist "$binary"; then
            	print_info "Removing SGID bit from $binary"
            	chmod g-s "$binary"
            	print_info "Removed SGID bit from $binary"
        	fi
    	done

	set_caps_if_present() {
    	local caps="$1"
    	local binary_path="$2"
    	if [ -f "$binary_path" ]; then
        	print_info "Setting caps $caps on $binary_path"
        	setcap "$caps" "$binary_path"
        	print_info "Set caps $caps on $binary_path"
    	fi
	}

	set_caps_if_present "cap_dac_read_search,cap_audit_write=ep" "/usr/bin/chage"
	set_caps_if_present "cap_sys_admin=ep" "/usr/bin/fusermount3"
	set_caps_if_present "cap_dac_read_search,cap_audit_write=ep" "/usr/sbin/unix_chkpwd"
	print_success "Remove_suid_root_from_known_binaries completed..."
}
functions_list="$functions_list Remove_suid_root_from_known_binaries"
