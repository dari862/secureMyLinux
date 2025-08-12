check_local_overrides(){
	check_local_overrides_path="${bin_path}/check_local_overrides"
	[ -f "$check_local_overrides" ] && return
	tee "$check_local_overrides" >/dev/null <<-EOF
	#!/bin/bash
	diff -r \
		--suppress-common-lines \
		--color="always" \
		--exclude "passwd*" \
		--exclude "group*" \
		--exclude="subgid*" \
		--exclude="subuid*" \
		--exclude="machine-id" \
		--exclude="adjtime" \
		--exclude="fstab" \
		--exclude="system-connections" \
		--exclude="shadow*" \
		--exclude="gshadow*" \
		--exclude="ssh_host*" \
		--exclude="cmdline" \
		--exclude="crypttab" \
		--exclude="hostname" \
		--exclude="localtime" \
		--exclude="locale*" \
		--exclude="*lock" \
		--exclude=".updated" \
		--exclude="*LOCK" \
		--exclude="vconsole*" \
		--exclude="00-keyboard.conf" \
		--exclude="grub" \
		--exclude="system.control*" \
		--exclude="cdi" \
		--exclude="default.target" \
		/usr/etc /etc 2>/dev/null | sed '/Binary\ files\ /d'
	EOF
	  chmod +x "$check_local_overrides"
      print_success "check_local_overrides completed"
}
functions_list="$functions_list check_local_overrides"
