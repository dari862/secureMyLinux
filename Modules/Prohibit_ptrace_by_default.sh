Prohibit_ptrace_by_default(){
	[ -f "/etc/sysctl.d/99-ptrace.conf" ] && return
	print_info "Prohibit ptrace by default"
	tee /etc/sysctl.d/99-ptrace.conf  > /dev/null <<-EOF
	kernel.yama.ptrace_scope=3
	EOF
	sysctl -p /etc/sysctl.d/99-ptrace.conf
	print_success "Prohibit_ptrace_by_default completed..."
}
functions_list="$functions_list Prohibit_ptrace_by_default"
