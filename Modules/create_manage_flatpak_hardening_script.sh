create_manage_flatpak_hardening_script(){
	! command -v flatpak >/dev/null 2>&1 && return
	manage_flatpak_hardening_path="${bin_path}/manage_flatpak_hardening"
	[ -f "$manage_flatpak_hardening" ] && return
	tee "$manage_flatpak_hardening" >/dev/null <<-EOF
	#!/bin/bash
	if [ "${EUID:-$(id -u)}" -ne 0 ]; then
  		printf "Please run as root"
  		exit 1
	fi
	harden_flatpak(){
		# Harden flatpaks by preloading hardened_malloc (highest supported hwcap). When called with a flatpak application ID as an argument, applies the overrides to that application instead of globally.
    	flatpak_id="${1:-}"

    	# Determine best microarchitecture to use for hardened_malloc
    	best_uarch="$(/usr/lib64/ld-linux-x86-64.so.2 --help | grep -F '(supported, searched)' \
        	| grep -o 'x86-64-v[[:digit:]]*' | sort -nr | head -n1 || echo '')"
    	readonly best_uarch
    	readonly hmalloc_path="/var/run/host/usr/lib64/${best_uarch:+"glibc-hwcaps/$best_uarch/"}libhardened_malloc.so"
    	readonly hmalloc_description="hardened_malloc${best_uarch:+" (µarch $best_uarch)"}"

    	if [[ -z "$flatpak_id" ]]; then
        	flatpak override --user --filesystem=host-os:ro
        	flatpak override --user --env=LD_PRELOAD="$hmalloc_path"
        	echo "$hmalloc_description applied to all flatpaks by default."
        	exit
    	fi

    	readonly override_dir="$HOME/.local/share/flatpak/overrides"

    	has_host_os_access() {
        	grep -Eqx 'filesystems=(.*;)?host-os(:ro)?(;.*)?' "$override_dir/$1"
    	}

    	remove_no_host_os() {
        	sed -Ei '/^filesystems=/s/!host-os(;|$)//' "$override_dir/$1"
    	}

    	has_ld_preload() {
        	grep -Fqx "LD_PRELOAD=$hmalloc_path" "$override_dir/$1"
    	}

    	remove_ld_preload_override() {
        	sed -i '/^LD_PRELOAD=/d' "$override_dir/$1"
    	}

    	harden_flatpak_app() {
        	if has_host_os_access 'global'; then
            	remove_no_host_os "$1"
        	else
            	flatpak override --user --filesystem=host-os:ro "$1"
        	fi
        	if has_ld_preload 'global'; then
            	remove_ld_preload_override "$1"
        	else
            	flatpak override --user --env=LD_PRELOAD="$hmalloc_path" "$1"
        	fi
    	}

    	installed_app_ids="$(flatpak list --columns=application --app)"
    	if ! echo "$installed_app_ids" | grep -Fqx "$flatpak_id"; then
        	echo "'$flatpak_id' is not the application ID of an installed flatpak."
        	readarray -t matching_ids < <(echo "$installed_app_ids" | grep -Fi "$flatpak_id")
        	if (( ${#matching_ids[@]} == 0 )); then
            	echo "No matching IDs found; exiting."
            	exit 1
        	fi
        	echo "Did you mean one of the following? (enter number to select, any letter to cancel)"
        	select selected_id in "${matching_ids[@]}"; do
            	if [[ -z "$selected_id" ]]; then
                	exit 1
            	fi
            	flatpak_id="$selected_id"
            	break
        	done
    	fi

    	harden_flatpak_app "$flatpak_id"
    	echo "$hmalloc_description applied to flatpak $flatpak_id"
	}
	flatpak_permissions_lockdown(){
	# Harden Flatpaks further by disabling all permissions by default and rejecting known arbitrary DBus names, applies only to the current user
    	kCommand="flatpak override --user"
    	kSharePermissions=("network" "ipc")
    	kSocketPermissions=("inherit-wayland-socket" "gpg-agent" "cups" "pcsc" "ssh-auth" "system-bus" "session-bus" "pulseaudio" "fallback-x11" "x11")
    	kDevicePermissions=("all" "shm" "kvm" "input" "usb")
    	kFeaturePermissions=("per-app-dev-shm" "canbus" "bluetooth" "multiarch" "devel")
    	kFilesystemPermissions=("home" "host-etc" "host")
    	kDangerousFilesystemPermissions=("~/.bashrc" "~/.bash_profile" "/home" "/var/home" "/var" "/media" "/run/media" "/run" "/mnt")
    	kKnownSessionBusNames=("org.xfce.ScreenSaver" "org.mate.ScreenSaver" "org.cinnamon.ScreenSaver" "org.gnome.ScreenSaver" "org.kde.kwalletd6" "org.gnome.Mutter.IdleMonitor.*" "org.gnome.ControlCenter" "org.gnome.Settings" "org.gnome.SettingsDaemon.MediaKeys" "org.gnome.SessionManager" "org.gnome.Shell.Screenshot" "org.kde.kiod5" "org.kde.kwin.Screenshot" "org.kde.JobViewServer" "org.gtk.vfs.*" "org.freedesktop.secrets" "org.kde.kconfig.notify" "org.kde.kpasswdserver" "org.kde.*" "org.kde.StatusNotifierWatcher" "org.kde.kded6" "org.kde.kpasswdserver6" "org.kde.kiod6" "com.canonical.Unity" "org.freedesktop.Notifications" "org.freedesktop.FileManager1" "org.freedesktop.impl.portal.PermissionStore" "org.freedesktop.Flatpak" "com.canonical.AppMenu.Registrar" "org.kde.KGlobalSettings" "org.kde.kded5" "com.canonical.Unity.LauncherEntry" "org.kde.kwalletd5" "org.gnome.SettingsDaemon" "org.a11y.Bus" "com.canonical.indicator.application" "org.freedesktop.ScreenSaver" "ca.desrt.dconf" "org.freedesktop.PowerManagement" "org.gnome.Software" "org.freedesktop.Tracker3.Writeback" "io.missioncenter.MissionCenter.Gatherer")
    	kKnownSystemBusNames=("org.bluez" "org.freedesktop.home1" "org.freedesktop.hostname1" "org.freedesktop.import1" "org.freedesktop.locale1" "org.freedesktop.LogControl1" "org.freedesktop.machine1" "org.freedesktop.network1" "org.freedesktop.oom1" "org.freedesktop.portable1" "org.freedesktop.resolve1" "org.freedesktop.sysupdate1" "org.freedesktop.timesync1" "org.freedesktop.timedate1" "org.freedesktop.systemd1" "org.freedesktop.Avahi" "org.freedesktop.Avahi.*" "org.freedesktop.login1" "org.freedesktop.NetworkManager" "org.freedesktop.UPower" "org.freedesktop.UDisks2" "org.freedesktop.fwupd")
    	kFlatsealNameAccess=("org.gnome.Software" "org.freedesktop.impl.portal.PermissionStore")
    	kWarehouseNameAccess=("org.freedesktop.Flatpak")
    	confirmation=""

    	echo "This will configure flatpak to automatically reject most permissions (with the exception of the Wayland socket and the Dri device, since these are commonly used and ensure at the very least most apps will work without crashing)."
    	echo "This will also grant Flatseal and Warehouse access to certain permissions to allow them to operate and make reconfiguring much easier."
    	echo "NOTE: This will break just about all Flatpaks by default, it is ON YOU to configure them to work with this configuration."
    	echo "NOTE 2: This DOES NOT enable hardened_malloc, use the harden-flatpak ujust command."
    	echo ""
    	read -rp "Would you like to proceed? [y/N] " confirmation
    	if [[ "$confirmation" == [Yy]* ]]; then
        	echo "-- Share Permissions --"
        	for i in "${kSharePermissions[@]}"; do
            	echo "	Rejecting $i..."
            	$kCommand --unshare="$i"
        	done
        	echo ""
        	echo "-- Socket Permissions --"
        	for i in "${kSocketPermissions[@]}"; do
            	echo "	Rejecting $i..."
            	$kCommand --nosocket="$i"
        	done
        	echo ""
        	echo "-- Device Permissions --"
        	for i in "${kDevicePermissions[@]}"; do
            	echo "	Rejecting $i..."
            	$kCommand --nodevice="$i"
        	done
        	echo ""
        	echo "-- Feature Permissions --"
        	for i in "${kFeaturePermissions[@]}"; do
            	echo "	Rejecting $i..."
            	$kCommand --disallow="$i"
        	done
        	echo ""
        	echo "-- Filesystem Permissions --"
        	for i in "${kFilesystemPermissions[@]}"; do
            	echo "	Rejecting $i..."
            	$kCommand --nofilesystem="$i"
        	done
        	echo ""
        	echo "-- Dangerous Filesystem Permissions --"
        	echo "Note: This is a VERY flawed implementation but it does cover a few blatant sandbox escape methods (such as the .bashrc escape or mounted drive access)"
        	echo "It is not possible to cover all files since each file can be requested manually and therefore must be rejected manually"
        	for i in "${kDangerousFilesystemPermissions[@]}"; do
            	echo "	Rejecting $i..."
            	$kCommand --nofilesystem="$i"
        	done
        	echo ""
        	echo "NOTE: The next 2 lockdowns are NOT complete and only cover a list of known names, this can be expanded at any time"
        	echo "-- Session Bus Name Access --"
        	for i in "${kKnownSessionBusNames[@]}"; do
            	echo "	Rejecting $i..."
            	$kCommand --no-talk-name="$i"
        	done
        	echo ""
        	echo "-- System Bus Name Access --"
        	for i in "${kKnownSystemBusNames[@]}"; do
            	echo "	Rejecting $i..."
            	$kCommand --system-no-talk-name="$i"
        	done
        	echo ""
        	echo "-- Persistent Filesystem Grant --"
        	echo "Note: This is to unbreak many Flatpaks by allowing the app to store persistent data in their own, isolated home directory without accessing the user's"
        	echo "	Granting access to persistent home..."
        	$kCommand --persist=.
        	echo ""
        	echo "-- Granting Access to Common Permissions --"
        	echo "Note: This will grant all apps access to some permissions to ensure most apps work by default, this also encourages the use of these permissions instead of their alternatives"
        	echo "	Granting access to Wayland and hardware acceleration..."
        	$kCommand --socket=wayland --device=dri
        	echo ""
        	echo "-- Granting Flatseal Access to Bus Names --"
        	for i in "${kFlatsealNameAccess[@]}"; do
            	echo "	Granting $i..."
            	$kCommand --talk-name="$i" com.github.tchx84.Flatseal
        	done
        	echo ""
        	echo "-- Granting Warehouse Access to Bus Names --"
        	for i in "${kWarehouseNameAccess[@]}"; do
            	echo "	Granting $i..."
            	$kCommand --talk-name="$i" io.github.flattool.Warehouse
        	done
        	echo ""
        	echo "Done"
    	fi
	}
	flatpak_reset_global_override(){
    	# Resets Flatpak's global overrides
    	GLOBAL_OVERRIDES="$HOME/.local/share/flatpak/overrides/global"
    	echo "This will undo the flatpak-harden command, the flatpak-permissions-lockdown command, as well as any other global overrides (individual app overrides will not be affected)."
    	echo "It will not delete the file, but simply move it from $GLOBAL_OVERRIDES to $GLOBAL_OVERRIDES.save"
    	mv "$GLOBAL_OVERRIDES" "$GLOBAL_OVERRIDES.save"
	}
	case "${1:-}" in
		harden) harden_flatpak "${2:-}" ;;
		lockdown) flatpak_permissions_lockdown ;;
		reset) flatpak_reset_global_override ;;
	esac
	EOF
	chmod +x "$manage_flatpak_hardening"
	print_success "script $manage_flatpak_hardening created."
}
functions_list="$functions_list create_manage_flatpak_hardening_script"
