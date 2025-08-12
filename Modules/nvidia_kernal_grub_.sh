nvidia_kernal_grub_(){
	KERNEL_ARGS="rd.driver.blacklist=nouveau modprobe.blacklist=nouveau nvidia-drm.modeset=1 nvidia-drm.fbdev=1"
	grep -q "$KERNEL_ARGS" /etc/default/grub && return
	
	GRUB_FILE="/etc/default/grub"
	BACKUP_FILE="/etc/default/grub.bak.$(date +%F-%H%M%S)"

	print_info "Creating backup of GRUB config at: $BACKUP_FILE"
	cp "$GRUB_FILE" "$BACKUP_FILE"

	print_info "Modifying GRUB_CMDLINE_LINUX_DEFAULT..."
	sed -i -E \
  	"s|^GRUB_CMDLINE_LINUX_DEFAULT=.*|GRUB_CMDLINE_LINUX_DEFAULT=\"${KERNEL_ARGS}\"|" \
  	"$GRUB_FILE"

	grub_update=true
}
functions_list="$functions_list nvidia_kernal_grub_"
