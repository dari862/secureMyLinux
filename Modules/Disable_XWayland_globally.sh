Disable_XWayland_globally(){
	[ -f "/etc/profile.d/disable-xwayland.sh" ] && return
	print_info "Disable XWayland globally"
	tee /etc/profile.d/disable-xwayland.sh  > /dev/null <<-EOF
	if [ "\$XDG_SESSION_TYPE" = wayland ]; then
  		export MOZ_ENABLE_WAYLAND=1
  		export QT_QPA_PLATFORM=wayland
  		echo XWayland disabled in Wayland session
	fi
	EOF
	chmod +x /etc/profile.d/disable-xwayland.sh
	print_success "Disable_XWayland_globally completed..."
}
functions_list="$functions_list Disable_XWayland_globally"
