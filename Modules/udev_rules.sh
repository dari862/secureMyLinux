udev_rules(){
	for r in 50-framework16 50-usb-realtek-net 70-titan-key 70-u2f 70-wooting Disable_binfmt_mis 99-thinkpad-thresholds-udev 92-viia 90-apple-superdrive 88-neutron_hifi_dac;do
		[ -f "/etc/udev/rules.d/${r}.rules" ] && return_now=true
	done
	[ "$return_now" = true ] && return
	mkdir -p /etc/udev/rules.d/
	tee "/etc/udev/rules.d/50-framework16.rules" >/dev/null 2>&1 <<-EOF
	# Audio Expansion Card
	ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="32ac", ATTR{idProduct}=="0010", ATTR{power/autosuspend}="10", ATTR{power/control}="auto", GOTO="rules_end"

	# Framework Laptop 16 Keyboard Module - ANSI
	ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="32ac", ATTR{idProduct}=="0012", ATTR{power/autosuspend}="-1", ATTR{power/control}="on", ATTR{power/wakeup}="disabled", GOTO="rules_end"

	# Framework Laptop 16 Numpad Module
	ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="32ac", ATTR{idProduct}=="0014", ATTR{power/autosuspend}="-1", ATTR{power/control}="on", ATTR{power/wakeup}="disabled", GOTO="rules_end"

	# Framework Laptop 16 Keyboard Module
	ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="32ac", ATTR{idProduct}=="0018", ATTR{power/autosuspend}="-1", ATTR{power/control}="on", ATTR{power/wakeup}="disabled", GOTO="rules_end"

	LABEL="rules_end"
	EOF
	tee "/etc/udev/rules.d/50-usb-realtek-net.rules" >/dev/null 2>&1 <<-EOF
	# This is used to change the default configuration of Realtek USB ethernet adapters

	ACTION!="add", GOTO="usb_realtek_net_end"
	SUBSYSTEM!="usb", GOTO="usb_realtek_net_end"
	ENV{DEVTYPE}!="usb_device", GOTO="usb_realtek_net_end"

	# Modify this to change the default value
	ENV{REALTEK_MODE1}="1"
	ENV{REALTEK_MODE2}="3"

	# Realtek
	ATTR{idVendor}=="0bda", ATTR{idProduct}=="815[2,3,5,6]", ATTR{bConfigurationValue}!="$env{REALTEK_MODE1}", ATTR{bConfigurationValue}="$env{REALTEK_MODE1}"
	ATTR{idVendor}=="0bda", ATTR{idProduct}=="8053", ATTR{bcdDevice}=="e???", ATTR{bConfigurationValue}!="$env{REALTEK_MODE2}", ATTR{bConfigurationValue}="$env{REALTEK_MODE2}"

	# Samsung
	ATTR{idVendor}=="04e8", ATTR{idProduct}=="a101", ATTR{bConfigurationValue}!="$env{REALTEK_MODE1}", ATTR{bConfigurationValue}="$env{REALTEK_MODE1}"

	# Lenovo
	ATTR{idVendor}=="17ef", ATTR{idProduct}=="304f", ATTR{bConfigurationValue}!="$env{REALTEK_MODE1}", ATTR{bConfigurationValue}="$env{REALTEK_MODE1}"
	ATTR{idVendor}=="17ef", ATTR{idProduct}=="3052", ATTR{bConfigurationValue}!="$env{REALTEK_MODE1}", ATTR{bConfigurationValue}="$env{REALTEK_MODE1}"
	ATTR{idVendor}=="17ef", ATTR{idProduct}=="3054", ATTR{bConfigurationValue}!="$env{REALTEK_MODE1}", ATTR{bConfigurationValue}="$env{REALTEK_MODE1}"
	ATTR{idVendor}=="17ef", ATTR{idProduct}=="3057", ATTR{bConfigurationValue}!="$env{REALTEK_MODE1}", ATTR{bConfigurationValue}="$env{REALTEK_MODE1}"
	ATTR{idVendor}=="17ef", ATTR{idProduct}=="3062", ATTR{bConfigurationValue}!="$env{REALTEK_MODE1}", ATTR{bConfigurationValue}="$env{REALTEK_MODE1}"
	ATTR{idVendor}=="17ef", ATTR{idProduct}=="3069", ATTR{bConfigurationValue}!="$env{REALTEK_MODE1}", ATTR{bConfigurationValue}="$env{REALTEK_MODE1}"
	ATTR{idVendor}=="17ef", ATTR{idProduct}=="3082", ATTR{bConfigurationValue}!="$env{REALTEK_MODE1}", ATTR{bConfigurationValue}="$env{REALTEK_MODE1}"
	ATTR{idVendor}=="17ef", ATTR{idProduct}=="3098", ATTR{bConfigurationValue}!="$env{REALTEK_MODE1}", ATTR{bConfigurationValue}="$env{REALTEK_MODE1}"
	ATTR{idVendor}=="17ef", ATTR{idProduct}=="7205", ATTR{bConfigurationValue}!="$env{REALTEK_MODE1}", ATTR{bConfigurationValue}="$env{REALTEK_MODE1}"
	ATTR{idVendor}=="17ef", ATTR{idProduct}=="720a", ATTR{bConfigurationValue}!="$env{REALTEK_MODE1}", ATTR{bConfigurationValue}="$env{REALTEK_MODE1}"
	ATTR{idVendor}=="17ef", ATTR{idProduct}=="720b", ATTR{bConfigurationValue}!="$env{REALTEK_MODE1}", ATTR{bConfigurationValue}="$env{REALTEK_MODE1}"
	ATTR{idVendor}=="17ef", ATTR{idProduct}=="720c", ATTR{bConfigurationValue}!="$env{REALTEK_MODE1}", ATTR{bConfigurationValue}="$env{REALTEK_MODE1}"
	ATTR{idVendor}=="17ef", ATTR{idProduct}=="7214", ATTR{bConfigurationValue}!="$env{REALTEK_MODE1}", ATTR{bConfigurationValue}="$env{REALTEK_MODE1}"
	ATTR{idVendor}=="17ef", ATTR{idProduct}=="721e", ATTR{bConfigurationValue}!="$env{REALTEK_MODE1}", ATTR{bConfigurationValue}="$env{REALTEK_MODE1}"
	ATTR{idVendor}=="17ef", ATTR{idProduct}=="8153", ATTR{bConfigurationValue}!="$env{REALTEK_MODE1}", ATTR{bConfigurationValue}="$env{REALTEK_MODE1}"
	ATTR{idVendor}=="17ef", ATTR{idProduct}=="a359", ATTR{bConfigurationValue}!="$env{REALTEK_MODE1}", ATTR{bConfigurationValue}="$env{REALTEK_MODE1}"
	ATTR{idVendor}=="17ef", ATTR{idProduct}=="a387", ATTR{bConfigurationValue}!="$env{REALTEK_MODE1}", ATTR{bConfigurationValue}="$env{REALTEK_MODE1}"

	# TP-LINK
	ATTR{idVendor}=="2357", ATTR{idProduct}=="0601", ATTR{bConfigurationValue}!="$env{REALTEK_MODE1}", ATTR{bConfigurationValue}="$env{REALTEK_MODE1}"

	# Nvidia
	ATTR{idVendor}=="0955", ATTR{idProduct}=="09ff", ATTR{bConfigurationValue}!="$env{REALTEK_MODE1}", ATTR{bConfigurationValue}="$env{REALTEK_MODE1}"

	# LINKSYS
	ATTR{idVendor}=="13b1", ATTR{idProduct}=="0041", ATTR{bConfigurationValue}!="$env{REALTEK_MODE1}", ATTR{bConfigurationValue}="$env{REALTEK_MODE1}"

	LABEL="usb_realtek_net_end"
	EOF
	tee "/etc/udev/rules.d/70-titan-key.rules" >/dev/null 2>&1 <<-EOF
	KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="18d1|096e", ATTRS{idProduct}=="5026|0858|085b", TAG+="uaccess"
	EOF
	tee "/etc/udev/rules.d/70-u2f.rules" >/dev/null 2>&1 <<-EOF
	# Copyright (C) 2013-2015 Yubico AB
	#
	# This program is free software; you can redistribute it and/or modify it
	# under the terms of the GNU Lesser General Public License as published by
	# the Free Software Foundation; either version 2.1, or (at your option)
	# any later version.
	#
	# This program is distributed in the hope that it will be useful, but
	# WITHOUT ANY WARRANTY; without even the implied warranty of
	# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser
	# General Public License for more details.
	#
	# You should have received a copy of the GNU Lesser General Public License
	# along with this program; if not, see <http://www.gnu.org/licenses/>.

	# this udev file should be used with udev 188 and newer
	ACTION!="add|change", GOTO="u2f_end"

	# Yubico YubiKey
	KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="1050", ATTRS{idProduct}=="0113|0114|0115|0116|0120|0121|0200|0402|0403|0406|0407|0410", TAG+="uaccess", GROUP="plugdev", MODE="0660"

	# Happlink (formerly Plug-Up) Security KEY
	KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="2581", ATTRS{idProduct}=="f1d0", TAG+="uaccess", GROUP="plugdev", MODE="0660"

	# Neowave Keydo and Keydo AES
	KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="1e0d", ATTRS{idProduct}=="f1d0|f1ae", TAG+="uaccess", GROUP="plugdev", MODE="0660"

	# HyperSecu HyperFIDO
	KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="096e|2ccf", ATTRS{idProduct}=="0880", TAG+="uaccess", GROUP="plugdev", MODE="0660"

	# Feitian ePass FIDO, BioPass FIDO2
	KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="096e", ATTRS{idProduct}=="0850|0852|0853|0854|0856|0858|085a|085b|085d|0866|0867", TAG+="uaccess", GROUP="plugdev", MODE="0660"

	# JaCarta U2F
	KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="24dc", ATTRS{idProduct}=="0101|0501", TAG+="uaccess", GROUP="plugdev", MODE="0660"

	# U2F Zero
	KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="10c4", ATTRS{idProduct}=="8acf", TAG+="uaccess", GROUP="plugdev", MODE="0660"

	# VASCO SecureClick
	KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="1a44", ATTRS{idProduct}=="00bb", TAG+="uaccess", GROUP="plugdev", MODE="0660"

	# Bluink Key
	KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="2abe", ATTRS{idProduct}=="1002", TAG+="uaccess", GROUP="plugdev", MODE="0660"

	# Thetis Key
	KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="1ea8", ATTRS{idProduct}=="f025", TAG+="uaccess", GROUP="plugdev", MODE="0660"

	# Nitrokey FIDO U2F, Nitrokey FIDO2, Safetech SafeKey
	KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="20a0", ATTRS{idProduct}=="4287|42b1|42b3", TAG+="uaccess", GROUP="plugdev", MODE="0660"

	# Google Titan U2F
	KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="18d1", ATTRS{idProduct}=="5026", TAG+="uaccess", GROUP="plugdev", MODE="0660"

	# Tomu board + chopstx U2F + SoloKeys
	KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="cdab|a2ca", TAG+="uaccess", GROUP="plugdev", MODE="0660"

	# SoloKeys
	KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="1209", ATTRS{idProduct}=="5070|50b0", TAG+="uaccess", GROUP="plugdev", MODE="0660"

	# Trezor
	KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="534c", ATTRS{idProduct}=="0001", TAG+="uaccess", GROUP="plugdev", MODE="0660"
	KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="1209", ATTRS{idProduct}=="53c1", TAG+="uaccess", GROUP="plugdev", MODE="0660"

	# Infineon FIDO
	KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="058b", ATTRS{idProduct}=="022d", TAG+="uaccess", GROUP="plugdev", MODE="0660"

	# Ledger Blue, Nano S and Nano X
	KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="2c97", ATTRS{idProduct}=="0000|0001|0004|0005|0015|1005|1015|4005|4015", TAG+="uaccess", GROUP="plugdev", MODE="0660"

	# Kensington VeriMark
	KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="06cb", ATTRS{idProduct}=="0088", TAG+="uaccess", GROUP="plugdev", MODE="0660"

	# Longmai mFIDO
	KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="4c4d", ATTRS{idProduct}=="f703", TAG+="uaccess", GROUP="plugdev", MODE="0660"

	# eWBM FIDO2 - Goldengate 310, 320, 500, 450
	KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="311f", ATTRS{idProduct}=="4a1a|4c2a|5c2f|f47c", TAG+="uaccess", GROUP="plugdev", MODE="0660"

	# OnlyKey (FIDO2 / U2F)
	KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="1d50", ATTRS{idProduct}=="60fc", TAG+="uaccess", GROUP="plugdev", MODE="0660"

	# GoTrust Idem Key
	KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="1fc9", ATTRS{idProduct}=="f143", TAG+="uaccess", GROUP="plugdev", MODE="0660"

	# ellipticSecure MIRKey
	KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="a2ac", TAG+="uaccess", GROUP="plugdev", MODE="0660"

	LABEL="u2f_end"
	EOF
	tee "/etc/udev/rules.d/70-wooting.rules" >/dev/null 2>&1 <<-EOF
	# Wooting One Legacy
	SUBSYSTEM=="hidraw", ATTRS{idVendor}=="03eb", ATTRS{idProduct}=="ff01", MODE="0660", TAG+="uaccess"
	SUBSYSTEM=="usb", ATTRS{idVendor}=="03eb", ATTRS{idProduct}=="ff01", MODE="0660", TAG+="uaccess"
	# Wooting One update mode
	SUBSYSTEM=="hidraw", ATTRS{idVendor}=="03eb", ATTRS{idProduct}=="2402", MODE="0660", TAG+="uaccess"

	# Wooting Two Legacy
	SUBSYSTEM=="hidraw", ATTRS{idVendor}=="03eb", ATTRS{idProduct}=="ff02", MODE="0660", TAG+="uaccess"
	SUBSYSTEM=="usb", ATTRS{idVendor}=="03eb", ATTRS{idProduct}=="ff02", MODE="0660", TAG+="uaccess"
	# Wooting Two update mode
	SUBSYSTEM=="hidraw", ATTRS{idVendor}=="03eb", ATTRS{idProduct}=="2403", MODE="0660", TAG+="uaccess"

	# Wooting One
	SUBSYSTEM=="hidraw", ATTRS{idVendor}=="31e3", ATTRS{idProduct}=="1100", MODE="0660", TAG+="uaccess"
	SUBSYSTEM=="usb", ATTRS{idVendor}=="31e3", ATTRS{idProduct}=="1100", MODE="0660", TAG+="uaccess"
	# Wooting One Alt-gamepad mode
	SUBSYSTEM=="hidraw", ATTRS{idVendor}=="31e3", ATTRS{idProduct}=="1101", MODE="0660", TAG+="uaccess"
	SUBSYSTEM=="usb", ATTRS{idVendor}=="31e3", ATTRS{idProduct}=="1101", MODE="0660", TAG+="uaccess"
	# Wooting One 2nd Alt-gamepad mode
	SUBSYSTEM=="hidraw", ATTRS{idVendor}=="31e3", ATTRS{idProduct}=="1102", MODE="0660", TAG+="uaccess"
	SUBSYSTEM=="usb", ATTRS{idVendor}=="31e3", ATTRS{idProduct}=="1102", MODE="0660", TAG+="uaccess"

	# Wooting Two
	SUBSYSTEM=="hidraw", ATTRS{idVendor}=="31e3", ATTRS{idProduct}=="1200", MODE="0660", TAG+="uaccess"
	SUBSYSTEM=="usb", ATTRS{idVendor}=="31e3", ATTRS{idProduct}=="1200", MODE="0660", TAG+="uaccess"
	# Wooting Two Alt-gamepad mode
	SUBSYSTEM=="hidraw", ATTRS{idVendor}=="31e3", ATTRS{idProduct}=="1201", MODE="0660", TAG+="uaccess"
	SUBSYSTEM=="usb", ATTRS{idVendor}=="31e3", ATTRS{idProduct}=="1201", MODE="0660", TAG+="uaccess"
	# Wooting Two 2nd Alt-gamepad mode
	SUBSYSTEM=="hidraw", ATTRS{idVendor}=="31e3", ATTRS{idProduct}=="1202", MODE="0660", TAG+="uaccess"
	SUBSYSTEM=="usb", ATTRS{idVendor}=="31e3", ATTRS{idProduct}=="1202", MODE="0660", TAG+="uaccess"

	# Wooting Lekker
	SUBSYSTEM=="hidraw", ATTRS{idVendor}=="31e3", ATTRS{idProduct}=="1210", MODE="0660", TAG+="uaccess"
	SUBSYSTEM=="usb", ATTRS{idVendor}=="31e3", ATTRS{idProduct}=="1210", MODE="0660", TAG+="uaccess"
	# Wooting Lekker Alt-gamepad mode
	SUBSYSTEM=="hidraw", ATTRS{idVendor}=="31e3", ATTRS{idProduct}=="1211", MODE="0660", TAG+="uaccess"
	SUBSYSTEM=="usb", ATTRS{idVendor}=="31e3", ATTRS{idProduct}=="1211", MODE="0660", TAG+="uaccess"
	# Wooting Lekker 2nd Alt-gamepad mode
	SUBSYSTEM=="hidraw", ATTRS{idVendor}=="31e3", ATTRS{idProduct}=="1212", MODE="0660", TAG+="uaccess"
	SUBSYSTEM=="usb", ATTRS{idVendor}=="31e3", ATTRS{idProduct}=="1212", MODE="0660", TAG+="uaccess"

	# Wooting Lekker update mode
	SUBSYSTEM=="hidraw", ATTRS{idVendor}=="31e3", ATTRS{idProduct}=="121f", MODE="0660", TAG+="uaccess"

	# Wooting Two HE
	SUBSYSTEM=="hidraw", ATTRS{idVendor}=="31e3", ATTRS{idProduct}=="1220", MODE="0660", TAG+="uaccess"
	SUBSYSTEM=="usb", ATTRS{idVendor}=="31e3", ATTRS{idProduct}=="1220", MODE="0660", TAG+="uaccess"
	# Wooting Two HE Alt-gamepad mode
	SUBSYSTEM=="hidraw", ATTRS{idVendor}=="31e3", ATTRS{idProduct}=="1221", MODE="0660", TAG+="uaccess"
	SUBSYSTEM=="usb", ATTRS{idVendor}=="31e3", ATTRS{idProduct}=="1221", MODE="0660", TAG+="uaccess"
	# Wooting Two HE 2nd Alt-gamepad mode
	SUBSYSTEM=="hidraw", ATTRS{idVendor}=="31e3", ATTRS{idProduct}=="1222", MODE="0660", TAG+="uaccess"
	SUBSYSTEM=="usb", ATTRS{idVendor}=="31e3", ATTRS{idProduct}=="1222", MODE="0660", TAG+="uaccess"

	# Wooting Two HE update mode
	SUBSYSTEM=="hidraw", ATTRS{idVendor}=="31e3", ATTRS{idProduct}=="122f", MODE="0660", TAG+="uaccess"

	# Wooting Two HE (ARM)
	SUBSYSTEM=="hidraw", ATTRS{idVendor}=="31e3", ATTRS{idProduct}=="1230", MODE="0660", TAG+="uaccess"
	SUBSYSTEM=="usb", ATTRS{idVendor}=="31e3", ATTRS{idProduct}=="1230", MODE="0660", TAG+="uaccess"
	# Wooting Two HE Alt-gamepad mode
	SUBSYSTEM=="hidraw", ATTRS{idVendor}=="31e3", ATTRS{idProduct}=="1231", MODE="0660", TAG+="uaccess"
	SUBSYSTEM=="usb", ATTRS{idVendor}=="31e3", ATTRS{idProduct}=="1231", MODE="0660", TAG+="uaccess"
	# Wooting Two HE 2nd Alt-gamepad mode
	SUBSYSTEM=="hidraw", ATTRS{idVendor}=="31e3", ATTRS{idProduct}=="1232", MODE="0660", TAG+="uaccess"
	SUBSYSTEM=="usb", ATTRS{idVendor}=="31e3", ATTRS{idProduct}=="1232", MODE="0660", TAG+="uaccess"

	# Wooting Two HE (ARM) update mode
	SUBSYSTEM=="hidraw", ATTRS{idVendor}=="31e3", ATTRS{idProduct}=="123f", MODE="0660", TAG+="uaccess"

	# Wooting 60HE
	SUBSYSTEM=="hidraw", ATTRS{idVendor}=="31e3", ATTRS{idProduct}=="1300", MODE="0660", TAG+="uaccess"
	SUBSYSTEM=="usb", ATTRS{idVendor}=="31e3", ATTRS{idProduct}=="1300", MODE="0660", TAG+="uaccess"
	# Wooting 60HE Alt-gamepad mode
	SUBSYSTEM=="hidraw", ATTRS{idVendor}=="31e3", ATTRS{idProduct}=="1301", MODE="0660", TAG+="uaccess"
	SUBSYSTEM=="usb", ATTRS{idVendor}=="31e3", ATTRS{idProduct}=="1301", MODE="0660", TAG+="uaccess"
	# Wooting 60HE 2nd Alt-gamepad mode
	SUBSYSTEM=="hidraw", ATTRS{idVendor}=="31e3", ATTRS{idProduct}=="1302", MODE="0660", TAG+="uaccess"
	SUBSYSTEM=="usb", ATTRS{idVendor}=="31e3", ATTRS{idProduct}=="1302", MODE="0660", TAG+="uaccess"

	# Wooting 60HE update mode
	SUBSYSTEM=="hidraw", ATTRS{idVendor}=="31e3", ATTRS{idProduct}=="130f", MODE="0660", TAG+="uaccess"

	# Wooting 60HE (ARM)
	SUBSYSTEM=="hidraw", ATTRS{idVendor}=="31e3", ATTRS{idProduct}=="1310", MODE="0660", TAG+="uaccess"
	SUBSYSTEM=="usb", ATTRS{idVendor}=="31e3", ATTRS{idProduct}=="1310", MODE="0660", TAG+="uaccess"
	# Wooting 60HE (ARM) Alt-gamepad mode
	SUBSYSTEM=="hidraw", ATTRS{idVendor}=="31e3", ATTRS{idProduct}=="1311", MODE="0660", TAG+="uaccess"
	SUBSYSTEM=="usb", ATTRS{idVendor}=="31e3", ATTRS{idProduct}=="1311", MODE="0660", TAG+="uaccess"
	# Wooting 60HE (ARM) 2nd Alt-gamepad mode
	SUBSYSTEM=="hidraw", ATTRS{idVendor}=="31e3", ATTRS{idProduct}=="1312", MODE="0660", TAG+="uaccess"
	SUBSYSTEM=="usb", ATTRS{idVendor}=="31e3", ATTRS{idProduct}=="1312", MODE="0660", TAG+="uaccess"

	# Wooting 60HE (ARM) update mode
	SUBSYSTEM=="hidraw", ATTRS{idVendor}=="31e3", ATTRS{idProduct}=="131f", MODE="0660", TAG+="uaccess"
	EOF
	tee "/etc/udev/rules.d/Disable_binfmt_mis.rules" >/dev/null 2>&1 <<-EOF
	# Disable binfmt_misc via sysctl when the module is loaded
	ACTION=="add", SUBSYSTEM=="module", DEVPATH=="/module/binfmt_misc", RUN+="/usr/bin/sysctl -w fs.binfmt_misc.status=0"
	EOF
	tee "/etc/udev/rules.d/99-thinkpad-thresholds-udev.rules" >/dev/null 2>&1 <<-EOF
	# Change the permissions of the battery threshold attributes so that they can be modified by ordinary users
	# See https://gitlab.com/marcosdalvarez/thinkpad-battery-threshold-extension

	ACTION=="add|change", KERNEL=="BAT[0-1]", GROUP="wheel" , SUBSYSTEM=="power_supply", TEST{0002}!="/sys%p/charge_control_start_threshold", RUN+="/bin/chmod 666 /sys%p/charge_control_start_threshold"
	ACTION=="add|change", KERNEL=="BAT[0-1]", GROUP="wheel" , SUBSYSTEM=="power_supply", TEST{0002}!="/sys%p/charge_control_end_threshold", RUN+="/bin/chmod 666 /sys%p/charge_control_end_threshold"
	ACTION=="add|change", KERNEL=="BAT[0-1]", GROUP="wheel" , SUBSYSTEM=="power_supply", TEST{0002}!="/sys%p/charge_start_threshold", RUN+="/bin/chmod 666 /sys%p/charge_start_threshold"
	ACTION=="add|change", KERNEL=="BAT[0-1]", GROUP="wheel" , SUBSYSTEM=="power_supply", TEST{0002}!="/sys%p/charge_stop_threshold", RUN+="/bin/chmod 666 /sys%p/charge_stop_threshold"
	EOF
	tee "/etc/udev/rules.d/92-viia.rules" >/dev/null 2>&1 <<-EOF
	KERNEL=="hidraw*", SUBSYSTEM=="hidraw", MODE="0666", TAG+="uaccess", TAG+="udev-acl"
	EOF
	tee "/etc/udev/rules.d/90-apple-superdrive.rules" >/dev/null 2>&1 <<-EOF
	# Apple SuperDrive udev rule
	# Credits: @yookoala from GitHub
	# See: https://gist.github.com/yookoala/818c1ff057e3d965980b7fd3bf8f77a6

	ACTION=="add", ATTRS{idProduct}=="1500", ATTRS{idVendor}=="05ac", DRIVERS=="usb", RUN+="/usr/bin/sg_raw %r/sr%n EA 00 00 00 00 00 01"
	EOF
	tee "/etc/udev/rules.d/88-neutron_hifi_dac.rules" >/dev/null 2>&1 <<-EOF
	# udev rule for Neutron HiFi DAC V1
	# https://neutronhifi.com/devices/dac/v1

	SUBSYSTEM=="usb", ATTRS{idVendor}=="1fc9", ATTRS{idProduct}=="82f9", MODE="0666"
	EOF
	print_success "udev_rules completed"
}
functions_list="$functions_list udev_rules"
