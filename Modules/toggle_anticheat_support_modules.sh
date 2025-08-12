toggle_anticheat_support_modules(){
	toggle_anticheat_support_path="${bin_path}/toggle_anticheat_support"
	[ -f "$toggle_anticheat_support_path" ] && return
	
	tee "$toggle_anticheat_support_path" >/dev/null <<-EOF
	#!/bin/bash
	# Toggle anticheat support by changing ptrace scope (requires restart)
	SYSCTL_HARDENING_FILE="/etc/sysctl.d/60-hardening.conf"
	if grep -q '^kernel.yama.ptrace_scope = 3' "$SYSCTL_HARDENING_FILE"; then
		sed -i 's/^kernel.yama.ptrace_scope =.*/kernel.yama.ptrace_scope = 1/' "$SYSCTL_HARDENING_FILE"
		echo "Anticheat support enabled. ptrace_scope set to 1."
	elif grep -q 'kernel.yama.ptrace_scope = 1' "$SYSCTL_HARDENING_FILE"; then
 		sed -i 's/^kernel.yama.ptrace_scope =.*/kernel.yama.ptrace_scope = 3/' "$SYSCTL_HARDENING_FILE"
 		echo "Anticheat support disabled. ptrace_scope set back to 3."
	else
		echo "The sysctl hardening file is missing the ptrace_scope setting."
	fi
	EOF
	chmod +x "$toggle_anticheat_support_path"
	print_success "script toggle_anticheat_support_modules created."
}
functions_list="$functions_list toggle_anticheat_support_modules"
