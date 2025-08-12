Enable_only_the_Flathub_verified_Flatpak_remote(){
	! command -v flatpak >/dev/null 2>&1 && return
	flatpak remotes | grep -q '^flathub' && return
	print_info "Enable only the Flathub-verified Flatpak remote"
	apt install -y flatpak
	flatpak remote-delete --system flathub || true
	flatpak remote-delete --user flathub || true

	flatpak remote-add --if-not-exists --user flathub \
  	https://dl.flathub.org/repo/flathub.flatpakrepo \
  	--no-gpg-verify

	flatpak remote-modify --user flathub --gpg-verify=true
	print_success "Flathub-verified remote enabled. Other remotes removed."
}
functions_list="$functions_list Enable_only_the_Flathub_verified_Flatpak_remote"
