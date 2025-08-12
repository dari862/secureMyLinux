setdrmvariables(){
	[ -f "/usr/lib/modprobe.d/nvidia-modeset.conf" ] && return
	tr /usr/lib/modprobe.d/nvidia-modeset.conf >/dev/null 2>&1 <<-EOF
	# Nvidia modesetting support. Set to 0 or comment to disable kernel modesetting
	# support. This must be disabled in case of SLI Mosaic.

	options nvidia-drm modeset=1 fbdev=1

	EOF
	cp /usr/lib/modprobe.d/nvidia-modeset.conf /etc/modprobe.d/nvidia-modeset.conf
	print_success "createmissingdirectories completed"
}
functions_list="$functions_list setdrmvariables"
