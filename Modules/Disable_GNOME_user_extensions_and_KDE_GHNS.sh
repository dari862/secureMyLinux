Disable_GNOME_user_extensions_and_KDE_GHNS(){
	[ -f "/etc/xdg/ghns" ] && [ -f "/etc/dconf/db/local.d/00-gnome-shell" ] && return
	print_info "Disable GNOME user extensions & KDE GHNS"
	# GNOME:
	# As root:
	mkdir -p /etc/dconf/db/local.d
	tee /etc/dconf/db/local.d/00-gnome-shell > /dev/null <<-EOF
	[org/gnome/shell]
	disable-user-extensions=true
	EOF

	mkdir -p /etc/dconf/db/local.d/locks
	echo "/org/gnome/shell/disable-user-extensions" > /etc/dconf/db/local.d/locks/disable-extensions

	dconf update
	# KDE GHNS disable by default by writing config
	mkdir -p /etc/xdg/ghns
	tee /etc/xdg/ghns/settings.ini > /dev/null <<-EOF
	[GHNS]
	Enabled=false
	EOF
	KDE_GLOBALS_FILE='/etc/xdg/kdeglobals'
	sed -i 's/^ghns=true.*/ghns=false/' "$KDE_GLOBALS_FILE"
	print_success "Disable_GNOME_user_extensions_and_KDE_GHNS completed..."
}
functions_list="$functions_list Disable_GNOME_user_extensions_and_KDE_GHNS"
