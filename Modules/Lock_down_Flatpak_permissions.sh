Lock_down_Flatpak_permissions(){
	! command -v flatpak >/dev/null 2>&1 && return
	flatpak override --user --show | grep -q && flatpak override --show | grep -q 'nosocket=x11' && flatpak override --user --show com.github.tchx84.Flatseal | grep -q 'xdg-data/flatpak/overrides:create' && return
	print_info "Lock down Flatpak permissions"
	apt install -y flatpak
	# Revoke dangerous permissions globally:
	flatpak override --system \
  		--nosocket=x11 --nosocket=fallback-x11 \
  		--nosocket=pulseaudio \
  		--nosocket=session-bus --nosocket=system-bus \
  		--unshare=network --unshare=ipc \
  		--nofilesystem=host:reset --nodevice=all \
  		--no-talk-name=org.freedesktop.Flatpak \
  		--no-talk-name=org.freedesktop.systemd1 \
  		--no-talk-name=ca.desrt.dconf \
  		--no-talk-name=org.gnome.Shell.Extensions

	flatpak override --user \
  		--nosocket=x11 --nosocket=fallback-x11 \
  		--nosocket=pulseaudio \
  		--nosocket=session-bus --nosocket=system-bus \
  		--unshare=network --unshare=ipc \
  		--nofilesystem=host:reset --nodevice=all \
  		--no-talk-name=org.freedesktop.Flatpak \
  		--no-talk-name=org.freedesktop.systemd1 \
  		--no-talk-name=ca.desrt.dconf \
  		--no-talk-name=org.gnome.Shell.Extensions

	# Allow user to still run Flatseal:
	flatpak override --user com.github.tchx84.Flatseal \
  		--filesystem=/var/lib/flatpak/app:ro \
  		--filesystem=xdg-data/flatpak/app:ro \
  		--filesystem=xdg-data/flatpak/overrides:create

	print_success "Lock_down_Flatpak_permissions completed..."
}
functions_list="$functions_list Lock_down_Flatpak_permissions"
