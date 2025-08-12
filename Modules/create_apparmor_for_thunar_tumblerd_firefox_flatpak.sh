create_apparmor_for_thunar_tumblerd_firefox_flatpak(){
	2check=""
	APPs_list=""
	for APP in thunar tumblerd firefox flatpak;do
		if command -v "$APP" >/dev/null 2>&1;then
			APPs_list="$APPs_list $APP"
			2check="${APP}|${2check}"
		fi
	done
	2check="${2check%|}"
	aa-status | grep -E "${2check}" && return
	print_info "Setting up AppArmor profiles for ${APPs_list}..."

	# Ask user whether to apply in enforce or complain mode
	read -rp "💬 Apply profiles in (e)nforce or (c)omplain mode? [e/c]: " MODE

	if [[ "$MODE" != "e" && "$MODE" != "c" ]]; then
    	print_error "Invalid choice. Use 'e' for enforce or 'c' for complain."
	fi

	# --- Thunar profile ---
	tee /etc/apparmor.d/usr.bin.thunar > /dev/null <<-'EOF'
	#include <tunables/global>

	/usr/bin/thunar {
  	include <abstractions/base>
  	include <abstractions/nameservice>
  	include <abstractions/X>
  	include <abstractions/dbus-session>
  	include <abstractions/fonts>
  	include <abstractions/user-tmp>

  	/usr/bin/thunar rix,
  	/usr/lib/thunar/** mr,

  	# Full user access
  	owner @{HOME}/** rwkl,

  	# Removable media
  	/media/** rwkl,
  	/mnt/** rwkl,

  	# Read-only system access
  	/etc/** r,
  	/usr/** r,
  	/bin/** r,
  	/sbin/** r,
  	/lib/** r,
  	/lib64/** r,
  	/boot/** r,
  	/opt/** r,
  	/srv/** r,

  	# Deny writes to system dirs
  	deny /etc/** wkl,
  	deny /usr/** wkl,
  	deny /bin/** wkl,
  	deny /sbin/** wkl,
  	deny /lib/** wkl,
  	deny /lib64/** wkl,
  	deny /boot/** wkl,
  	deny /opt/** wkl,
  	deny /srv/** wkl,

  	# Deny sensitive locations
  	deny /root/** rwkl,
  	deny /etc/shadow r,
  	deny /etc/sudoers r,
  	deny /proc/*/mem rw,
  	deny /proc/*/sysrq-trigger rw,

  	# Mount helpers
  	/usr/libexec/gvfsd rix,
  	/usr/libexec/gvfsd-fuse rix,
  	/usr/libexec/gvfs-udisks2-volume-monitor rix,
  	/usr/libexec/udisks2/udisksd rix,

  	dbus (send) bus=session path=/org/freedesktop/UDisks2 interface=org.freedesktop.DBus.*,
  	dbus (send) bus=system path=/org/freedesktop/UDisks2 interface=org.freedesktop.UDisks2.*,

  	# No network
  	deny network,

  	# Capabilities
  	capability sys_admin,
  	capability dac_override,
  	deny capability setuid,
  	deny capability setgid,
  	deny capability sys_module,
  	deny capability sys_ptrace,
  	deny capability net_admin,
  	deny capability kill,

  	/tmp/** rw,
  	/dev/shm/** rw,

  	/ r,
	}
	EOF

	# --- tumblerd profile ---
	tee /etc/apparmor.d/usr.bin.tumblerd > /dev/null <<-'EOF'
	#include <tunables/global>

	/usr/bin/tumblerd {
  	include <abstractions/base>
  	include <abstractions/nameservice>
  	include <abstractions/user-tmp>
  	include <abstractions/fonts>
  	include <abstractions/X>
  	include <abstractions/dbus-session>

  	/usr/bin/tumblerd rix,
  	/usr/lib/tumbler/** mr,

  	# Read-only access to previews
  	owner @{HOME}/Pictures/** r,
  	owner @{HOME}/Videos/** r,
  	owner @{HOME}/Documents/** r,

  	# Thumbnail cache
  	owner @{HOME}/.cache/thumbnails/** rwk,

  	# Deny sensitive areas
  	deny @{HOME}/.ssh/** rwkl,
  	deny @{HOME}/.gnupg/** rwkl,
  	deny /etc/shadow r,
  	deny /root/** rwkl,

  	deny network,
  	deny capability sys_admin,
  	deny capability sys_ptrace,
  	deny capability setuid,
  	deny capability setgid,

  	/tmp/** rw,
  	/dev/shm/** rw,

  	/ r,
	}
	EOF

	# ------------------------------
	# Firefox profile
	# ------------------------------
	tee /etc/apparmor.d/usr.bin.firefox > /dev/null <<-'EOF'
	#include <tunables/global>

	/usr/bin/firefox {
  	include <abstractions/base>
  	include <abstractions/nameservice>
  	include <abstractions/X>
  	include <abstractions/fonts>
  	include <abstractions/dbus-session>
  	include <abstractions/user-tmp>
  	include <abstractions/audio>

  	/usr/bin/firefox rix,
  	/usr/lib/firefox/** mr,
  	/etc/firefox/** r,
  	/usr/share/firefox/** r,

  	owner @{HOME}/.mozilla/** rwk,
  	owner @{HOME}/.cache/mozilla/** rwk,
  	owner @{HOME}/Downloads/** rw,
  	owner @{HOME}/Pictures/** rw,

  	audit deny @{HOME}/** rwkl,

  	deny /etc/shadow r,
  	deny /root/** rwkl,
  	deny /proc/*/mem rw,
  	deny /proc/*/sysrq-trigger rw,

  	network inet stream,
  	network inet6 stream,

  	capability net_bind_service,
  	deny capability sys_admin,
  	deny capability setuid,
  	deny capability setgid,
  	deny capability sys_module,
  	deny capability sys_ptrace,
  	deny capability kill,

  	/tmp/** rw,
  	/dev/shm/** rw,

  	/ r,
	}
	EOF

	# ------------------------------
	# Flatpak profile
	# ------------------------------
	tee /etc/apparmor.d/usr.bin.flatpak > /dev/null <<-'EOF'
	#include <tunables/global>

	/usr/bin/flatpak {
  	include <abstractions/base>
  	include <abstractions/nameservice>
  	include <abstractions/user-tmp>

  	/usr/bin/flatpak rix,
  	/usr/lib/flatpak/** mr,
  	/etc/flatpak/** r,
  	/var/lib/flatpak/** r,

  	owner @{HOME}/.local/share/flatpak/** rwk,

  	audit deny @{HOME}/** rwkl,

  	deny /usr/** w,
  	deny /etc/** w,

  	network inet stream,
  	network inet6 stream,

  	deny capability sys_admin,
  	deny capability setuid,
  	deny capability setgid,
  	deny capability sys_ptrace,
  	deny capability kill,

  	/tmp/** rw,
  	/dev/shm/** rw,

  	/ r,
	}
	EOF
	
	for APP in $APPs_list;do
		print_info "Loading AppArmor profile for $APP..."
		apparmor_parser -r "/etc/apparmor.d/usr.bin.$APP"
		if [[ "$MODE" == "e" ]]; then
			print_info "Applying in ENFORCE mode..."
			aa-enforce "/etc/apparmor.d/usr.bin.$APP"
		else
			print_info "Applying in COMPLAIN mode (log only)..."
			aa-complain "/etc/apparmor.d/usr.bin.$APP"
		fi
	done
	print_info "Current AppArmor status:"
	aa-status | grep -E "$2check"
	
	print_success "Profiles applied in ${MODE^^} mode."
}
functions_list="$functions_list create_apparmor_for_thunar_tumblerd_firefox_flatpak"
