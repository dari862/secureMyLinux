install_Hardened_malloc(){
  print_info "Installing hardened_malloc..."
  [ -f "/usr/lib/libhardened_malloc.so" ] && return
  apt install -y git build-essential gcc
  git clone https://github.com/GrapheneOS/hardened_malloc.git /tmp/hm
  (cd /tmp/hm && make)

  cp /tmp/hm/libhardened_malloc.so /usr/lib/libhardened_malloc.so
  mkdir -p /usr/lib/systemd/system.conf.d
    tee /usr/lib/systemd/system.conf.d/40-hardened_malloc.conf > /dev/null <<-EOF
	[Manager]
	DefaultEnvironment=LD_PRELOAD=libhardened_malloc.so
	EOF
  	tee /etc/profile.d/hardened_malloc.sh > /dev/null <<-EOF
	#!/usr/bin/sh
	export LD_PRELOAD=libhardened_malloc.so
	EOF
	chmod +x /etc/profile.d/hardened_malloc.sh
	tee /usr/lib/environment.d/40-hardened_malloc.conf > /dev/null <<-EOF
	LD_PRELOAD=libhardened_malloc.so
	EOF
	chmod +x /etc/profile.d/hardened_malloc.sh
  echo "/usr/lib/libhardened_malloc.so" | tee /etc/ld.so.preload > /dev/null
  # enlarge map count
	tee /etc/sysctl.d/99-hardened_malloc.conf > /dev/null <<-EOF
	# https://docs.kernel.org/admin-guide/sysctl/vm.html
	# Default in Fedora, including for runtime audit
	vm.mmap_min_addr=65536
	vm.max_map_count=1048576
	EOF
  sysctl -p /etc/sysctl.d/99-hardened_malloc.conf
  
  if command -v flatpak >/dev/null 2>&1;then
	  # 1b. Flatpak: workaround to allow ld_preload in many apps
	  print_info "Configuring Flatpak workaround..."
	  # copy lib locally, whitelist it
	  mkdir -p ~/.local/lib
	  cp /usr/lib/libhardened_malloc.so ~/.local/lib/
	  flatpak override --env=LD_PRELOAD=~/.local/lib/libhardened_malloc.so --filesystem=host-os:ro
  fi
  
  print_success "hardened_malloc installed..."
}
functions_list="$functions_list install_Hardened_malloc"
