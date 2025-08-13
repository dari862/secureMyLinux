setup_luks_fido2() {
	setup_tpm2_fido2_path="${bin_path}/setup-fido2-luks.sh"
	[ -f "$setup_tpm2_fido2_path" ] && return
  print_info "Setting up FIDO2 unlocking for LUKS..."
  
	print_info "Installing dependency..."
	apt install -y libfido2-dev libpam-fido2 libpam-u2f systemd-cryptsetup cryptsetup
	
	tee "$setup_tpm2_fido2_path" > /dev/null <<-'EOF'
	#!/bin/bash
	if [ "${EUID:-$(id -u)}" -ne 0 ]; then
  		printf "Please run as root"
  		exit 1
	fi
	DEVICE=$1
	[ -z "$DEVICE" ] && echo "Usage: $0 /dev/sdX" && exit 1
	echo "[*] Adding FIDO2 keyslot to $DEVICE..."
	systemd-cryptenroll --fido2-device=auto "$DEVICE"
	echo "[+] FIDO2 unlock setup complete."
	EOF
  chmod +x "$setup_tpm2_fido2_path"
  	print_info "-------------------------------------"
	print_info "Tools created:"
	print_info "$setup_tpm2_fido2_path /dev/sdX"
	print_info "Remember to BACK UP LUKS headers before running these scripts!"
	print_success "setup_luks_fido2 completed"
}
functions_list="$functions_list setup_luks_fido2"
