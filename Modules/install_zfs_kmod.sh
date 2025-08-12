install_zfs_kmod(){
	lsmod | grep -q zfs && return
    print_info "Downloading zfs."
    apt install zfs-dkms zfsutils-linux
    modprobe zfs || print_error "failed to modprobe zfs."
	lsmod | grep -q zfs || print_error "failed to load zfs."
    print_success "install_zfs_kmod completed successfully"
}
functions_list="$functions_list install_zfs_kmod"
