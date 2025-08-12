hardened_kernal_grub(){
	KERNEL_ARGS="init_on_alloc=1 init_on_free=1 slab_nomerge page_alloc.shuffle=1 randomize_kstack_offset=on vsyscall=none lockdown=confidentiality random.trust_cpu=off random.trust_bootloader=off iommu=force intel_iommu=on iommu.passthrough=0 iommu.strict=1 pti=on module.sig_enforce=1 mitigations=auto,nosmt spectre_v2=on spec_store_bypass_disable=on l1d_flush=on l1tf=full,force kvm-intel.vmentry_l1d_flush=always loglevel=0 rd.shell=0 rd.emergency=halt"
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
functions_list="$functions_list hardened_kernal_grub"
