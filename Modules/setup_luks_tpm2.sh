setup_luks_tpm2() {
  setup_tpm2_luks_path="${bin_path}/setup-tpm2-luks.sh"
  [ -f "$setup_tpm2_luks_path" ] && return
  print_info "Setting up TPM2 + PIN unlocking for LUKS..."
  
  print_info "Installing dependency..."
  apt install -y tpm2-tools tpm2-tss systemd-cryptsetup cryptsetup
  
  print_info "Checking for TPM2 device..."
  if [ ! -c /dev/tpmrm0 ]; then
    print_warning "TPM2 device not found. Skipping TPM2 setup."
    return
  fi

  print_info "Setting up TPM2 integration script..."
  
  	tee "$setup_tpm2_luks_path"  > /dev/null <<-'EOF'
	#!/bin/bash
	if [ "${EUID:-$(id -u)}" -ne 0 ]; then
  		printf "Please run as root"
  		exit 1
	fi
	DEVICE=$1
	[ -z "$DEVICE" ] && echo "Usage: $0 /dev/sdX" && exit 1

	echo "[*] Adding TPM2 keyslot to $DEVICE..."
	systemd-cryptenroll --tpm2-device=auto --recovery-key --pkcs11-token-uri=auto --pin=yes "$DEVICE"

	echo "[+] TPM2 + PIN unlock setup complete."
	EOF

  chmod +x "$setup_tpm2_luks_path"
    print_info "-------------------------------------"
	print_info "Tools created:"
	print_info "  /opt/luks-tools/setup-tpm2-luks.sh /dev/sdX"
	print_info "Remember to BACK UP LUKS headers before running these scripts!"
	print_success "setup_luks_tpm2 completed"
}
functions_list="$functions_list setup_luks_tpm2"
