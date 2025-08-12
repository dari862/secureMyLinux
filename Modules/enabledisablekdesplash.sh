enabledisablekdesplash(){
	[ "$(systemctl is-enabled disable-kde-splash.service 2>/dev/null)" = "enabled" ] && return
	systemctl --global enable disable-kde-splash.service
	print_success "enabledisablekdesplash completed"
}
functions_list="$functions_list enabledisablekdesplash"
