hardened_malloc_pam(){
	grep -q "LD_PRELOAD DEFAULT=libhardened_malloc.so" /etc/security/pam_env.conf && return
	sed -i -e '$a\LD_PRELOAD DEFAULT=libhardened_malloc.so' -e '/^LD_PRELOAD[[:space:]]/d' /etc/security/pam_env.conf
	print_success "hardened_malloc_pam completed"
}
functions_list="$functions_list hardened_malloc_pam"
