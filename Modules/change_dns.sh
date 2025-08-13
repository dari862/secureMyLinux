change_dns_script_module(){
	change_dns_path="${bin_path}/change_dns"
	[ -f "$change_dns_path" ] && return
	
	tee "$change_dns_path" >/dev/null <<-EOF
	#!/bin/bash
	# constants
	if [ "${EUID:-$(id -u)}" -ne 0 ]; then
  		printf "Please run as root"
  		exit 1
	fi
	readonly resolved_conf="/etc/systemd/resolved.conf.d/10-securedns.conf"
	mkdir -m 755 -p /etc/systemd/resolved.conf.d/
	# variables
	resolver_selection=""
	resolver_subselection=""
	resolver_has_second_ip=""
	resolver_supports_ipv6=""
	resolver_dnssec=""
	resolver_ipv4_address=""
	resolver_ipv4_address_2=""
	resolver_ipv6_address=""
	resolver_ipv6_address_2=""
	resolver_hostname=""
	resolver_https_address=""
	opportunistic=""

	while_loop(){
		while :; do
			read -rp "Selection [${1:-}]: " resolver_selection
			if [[ "$resolver_selection" == [${2:-}]* ]]; then
				break
			else
				echo "That is not a valid selection."
			fi
		done
	}

	echo "Below will be some options to set the DNS resolver for systemd-resolved."
	echo "All resolvers support DNS-over-TLS (DoT) or DNS-over-QUIC (DoQ), DNS-over-HTTPS (DoH), and DNSSEC."
	echo "Please select which DNS resolver you would like to set:"
	echo "0) Network Default - do nothing, rely purely on the network for resolution (when using a VPN, this option is best to guarentee usage of the VPN's DNS resolver)"
	echo "1) Opportunistic Upgrade - try to upgrade to DoT (encrypted DNS) resolution and/or DNSSEC enforcement (this configuration may break networking)"
	echo "2) Control D - has content filtering, anycast"
	echo "3) Mullvad - has content filtering, anycast"
	echo "4) Cloudflare - very fast with some data collection, anycast"
	echo "5) DNSForge - powerful filtering but can be very slow"
	echo "6) Custom Resolver - use a custom resolver (must support DoT/DoQ, ideally also supports DNSSEC, DoH support is also required to set a browser policy should that be desired)"

	while_loop "0-6" "0123456"

	echo ""
	case "$resolver_selection" in
		0)  echo "Resetting resolved to default state." ;;
		1)  opportunistic="1" ;;
		2)  resolver_has_second_ip="y"
			resolver_supports_ipv6="y"
			resolver_dnssec="y"
			echo "Setting resolver Control D."
			echo "What content would you like to filter:"
			echo "0) No filtering"
			echo "1) Malware: Malware filtering"
			echo "2) Standard: Malware + ad and tracker filtering"
			echo "3) Social: Standard + social media filtering"
			echo "4) Family: Social + adult content filtering (also enables safe search in major search engines)"
			while_loop "0-4" "01234"
			
			case "$resolver_subselection" in
			0)  resolver_ipv4_address="76.76.2.0"
				resolver_ipv4_address_2="76.76.10.0"
				resolver_ipv6_address="2606:1a40::"
				resolver_ipv6_address_2="2606:1a40:1::"
				resolver_hostname="p0.freedns.controld.com"
				resolver_https_address="https://freedns.controld.com/p0"
			;;
			1)  resolver_ipv4_address="76.76.2.1"
				resolver_ipv4_address_2="76.76.10.1"
				resolver_ipv6_address="2606:1a40::1"
				resolver_ipv6_address_2="2606:1a40:1::1"
				resolver_hostname="p1.freedns.controld.com"
				resolver_https_address="https://freedns.controld.com/p1"
			;;
			2)  resolver_ipv4_address="76.76.2.2"
				resolver_ipv4_address_2="76.76.10.2"
				resolver_ipv6_address="2606:1a40::2"
				resolver_ipv6_address_2="2606:1a40:1::2"
				resolver_hostname="p2.freedns.controld.com"
				resolver_https_address="https://freedns.controld.com/p2"
			;;
			3)  resolver_ipv4_address="76.76.2.3"
				resolver_ipv4_address_2="76.76.10.3"
				resolver_ipv6_address="2606:1a40::3"
				resolver_ipv6_address_2="2606:1a40:1::3"
				resolver_hostname="p3.freedns.controld.com"
				resolver_https_address="https://freedns.controld.com/p3"
			;;
			4)  resolver_ipv4_address="76.76.2.4"
				resolver_ipv4_address_2="76.76.10.4"
				resolver_ipv6_address="2606:1a40::4"
				resolver_ipv6_address_2="2606:1a40:1::4"
				resolver_hostname="family.freedns.controld.com"
				resolver_https_address="https://freedns.controld.com/family"
			;;
			esac
		;;
		3)  resolver_has_second_ip="n"
			resolver_supports_ipv6="y"
			resolver_dnssec="y"
			echo "Setting resolver Mullvad."
			echo "What content would you like to filter:"
			echo "0) No filtering"
			echo "1) Standard: Ad and tracker filtering"
			echo "2) Base: Standard + malware filtering"
			echo "3) Extended: Base + social media filtering"
			echo "4) Family: Base + gambling and adult content filtering"
			echo "5) All: Family + social media filtering"
			while_loop "0-5" "012345"
			
			case "$resolver_subselection" in
				0)  resolver_ipv4_address="194.242.2.2"
					resolver_ipv6_address="2a07:e340::2"
					resolver_hostname="dns.mullvad.net"
				;;
				1)  resolver_ipv4_address="194.242.2.3"
					resolver_ipv6_address="2a07:e340::3"
					resolver_hostname="adblock.dns.mullvad.net"
				;;
				2)  resolver_ipv4_address="194.242.2.4"
					resolver_ipv6_address="2a07:e340::4"
					resolver_hostname="base.dns.mullvad.net"
				;;
				3)  resolver_ipv4_address="194.242.2.5"
					resolver_ipv6_address="2a07:e340::5"
					resolver_hostname="extended.dns.mullvad.net"
				;;
				4)  resolver_ipv4_address="194.242.2.6"
					resolver_ipv6_address="2a07:e340::6"
					resolver_hostname="family.dns.mullvad.net"
				;;
				5)  resolver_ipv4_address="194.242.2.9"
					resolver_ipv6_address="2a07:e340::9"
					resolver_hostname="all.dns.mullvad.net"
				;;
			esac
			resolver_https_address="https://$resolver_hostname/dns-query"
		;;
		4)  resolver_has_second_ip="y"
			resolver_supports_ipv6="y"
			resolver_dnssec="y"
			echo "Setting resolver Cloudflare. (glory to the cloud)"
			echo "What content would you like to filter:"
			echo "0) No filtering"
			echo "1) Security: Malware filtering"
			echo "2) Family: Security + adult content filtering"
			while_loop "0-2" "012"
			
			case "$resolver_subselection" in
				0)  resolver_ipv4_address="1.1.1.1"
					resolver_ipv4_address_2="1.0.0.1"
					resolver_ipv6_address="2606:4700:4700::1111"
					resolver_ipv6_address_2="2606:4700:4700::1001"
					resolver_hostname="cloudflare-dns.com"
				;;
				1)  resolver_ipv4_address="1.1.1.2"
					resolver_ipv4_address_2="1.0.0.2"
					resolver_ipv6_address="2606:4700:4700::1112"
					resolver_ipv6_address_2="2606:4700:4700::1002"
					resolver_hostname="security.cloudflare-dns.com"
				;;
				2)  resolver_ipv4_address="1.1.1.3"
					resolver_ipv4_address_2="1.0.0.3"
					resolver_ipv6_address="2606:4700:4700::1113"
					resolver_ipv6_address_2="2606:4700:4700::1003"
					resolver_hostname="family.cloudflare-dns.com"
				;;
			esac
			resolver_https_address="https://$resolver_hostname/dns-query"
		;;
		5)  resolver_has_second_ip="y"
			resolver_supports_ipv6="y"
			resolver_dnssec="y"
			echo "Setting resolver DNSForge."
			echo "What content would you like to filter:"
			echo "0) Standard: Ad, tracker, and malware filtering"
			echo "1) Clean: Standard + adult content filtering"
			echo "2) Hard: Clean + stricter ad, tracker, and malware filtering"
			while_loop "0-2" "012"
			
			case "$resolver_subselection" in
				0)  resolver_ipv4_address="176.9.93.198"
					resolver_ipv4_address_2="176.9.1.117"
					resolver_ipv6_address="2a01:4f8:151:34aa::198"
					resolver_ipv6_address_2="2a01:4f8:141:316d::117"
					resolver_hostname="dnsforge.de"
				;;
				1)  resolver_ipv4_address="49.12.223.2"
					resolver_ipv4_address_2="49.12.43.208"
					resolver_ipv6_address="2a01:4f8:c17:4fbc::2"
					resolver_ipv6_address_2="2a01:4f8:c012:ed89::208"
					resolver_hostname="clean.dnsforge.de"
				;;
				2)  resolver_ipv4_address="49.12.222.213"
					resolver_ipv4_address_2="88.198.122.154"
					resolver_ipv6_address="2a01:4f8:c17:2c61::213"
					resolver_ipv6_address_2="2a01:4f8:c013:5ec0::154"
					resolver_hostname="hard.dnsforge.de"
				;;
			esac
			resolver_https_address="https://$resolver_hostname/dns-query"
		;;
		6)  echo "Setting custom resolver."
			echo "NOTE: If the resolver does not support DoT/DoQ or DNSSEC, this process will not work."
			echo ""
			echo "Please provide the technical information."
			read -rp "Please enter the resolver's IPv4 address (e.g. '1.1.1.2'): " resolver_ipv4_address
			read -rp "Does the resolver provide two distinct IPv4 addresses (e.g. '1.1.1.2' and '1.0.0.2')? [Y/n] " resolver_has_second_ip
			resolver_has_second_ip=${resolver_has_second_ip:-y}
			if [[ "$resolver_has_second_ip" == [Yy]* ]]; then
				read -rp "Please enter the resolver's second IPv4 address: " resolver_ipv4_address_2
			fi
			read -rp "Does the resolver support IPv6 (e.g. '2606:4700:4700::1112')? [Y/n] " resolver_supports_ipv6
			resolver_supports_ipv6=${resolver_supports_ipv6:-y}
			if [[ "$resolver_supports_ipv6" == [Yy]* ]]; then
				read -rp "Please enter the resolver's IPv6 address: " resolver_ipv6_address
				if [[ "$resolver_has_second_ip" == [Yy]* ]]; then
					read -rp "Please enter the resolver's second IPv6 address: " resolver_ipv6_address_2
				fi
			fi
			read -rp "Please enter the second resolver's hostname (e.g. 'security.cloudflare-dns.com'): " resolver_hostname
			read -rp "Do you want to enable DNSSEC (this can cause networking issues notably in virtual machines, it is recommended if you do not suffer issues)? [Y/n] " resolver_dnssec
			resolver_dnssec=${resolver_dnssec:-y}
		;;
	esac

	if [[ "$opportunistic" == "1" ]]; then
		tee "$resolved_conf" >/dev/null 2>&1 <<- EOF1
		[Resolve]
		DNSOverTLS=opportunistic
		DNSSEC=allow-downgrade
		EOF1
	else
		resolved_conf_dns_string=""
		resolved_conf_dns_string+="DNS="
		resolved_conf_dns_string+=" $resolver_ipv4_address"
		resolved_conf_dns_string+="#$resolver_hostname"
		if [[ "$resolver_has_second_ip" == [Yy]* ]]; then
			resolved_conf_dns_string+=" $resolver_ipv4_address_2"
			resolved_conf_dns_string+="#$resolver_hostname"
		fi
		if [[ "$resolver_supports_ipv6" == [Yy]* ]]; then
			resolved_conf_dns_string+=" $resolver_ipv6_address"
			resolved_conf_dns_string+="#$resolver_hostname"
			if [[ "$resolver_has_second_ip" == [Yy]* ]]; then
				resolved_conf_dns_string+=" $resolver_ipv6_address_2"
				resolved_conf_dns_string+="#$resolver_hostname"
			fi
		fi

		resolved_conf_dnssec_string=""
		if [[ "$resolver_dnssec" == [Yy]* ]]; then
			resolved_conf_dnssec_string+="DNSSEC=true"
		fi
		tee "$resolved_conf" >/dev/null 2>&1 <<- EOF2
		[Resolve]
		DNSOverTLS=true
		$resolved_conf_dns_string
		$resolved_conf_dnssec_string
		EOF2
	fi

	[ -f "$resolved_conf" ] && 	chmod 644 "$resolved_conf"

	systemctl restart systemd-resolved

	echo "Configation for resolved set and service restarted."
	EOF
	chmod +x "$change_dns_path"
	print_success "script change_dns created."
}
functions_list="$functions_list change_dns_script_module"
