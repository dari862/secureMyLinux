Enforcing_account_lockout_and_password_policies(){
	grep -q "# added by hardened script" /etc/security/faillock.conf /etc/security/pwquality.conf && return
	print_info "Enforcing account lockout and password policies"

	apt install -y libpam-pwquality

	# Fail2ban-style account locking (pam_tally2 is deprecated; use pam_faillock)
	tee /etc/security/faillock.conf > /dev/null <<-EOF
	# added by hardened script
	# Configuration for locking the user after multiple failed
	# authentication attempts.
	#
	# The directory where the user files with the failure records are kept.
	# The default is /var/run/faillock.
	# dir = /var/run/faillock
	#
	# Will log the user name into the system log if the user is not found.
	# Enabled if option is present.
	audit
	#
	# Don't print informative messages.
	# Enabled if option is present.
	# silent
	#
	# Don't log informative messages via syslog.
	# Enabled if option is present.
	# no_log_info
	#
	# Only track failed user authentications attempts for local users
	# in /etc/passwd and ignore centralized (AD, IdM, LDAP, etc.) users.
	# The `faillock` command will also no longer track user failed
	# authentication attempts. Enabling this option will prevent a
	# double-lockout scenario where a user is locked out locally and
	# in the centralized mechanism.
	# Enabled if option is present.
	# local_users_only
	#
	# Deny access if the number of consecutive authentication failures
	# for this user during the recent interval exceeds n tries.
	# The default is 3.
	deny = 50
	#
	# The length of the interval during which the consecutive
	# authentication failures must happen for the user account
	# lock out is <replaceable>n</replaceable> seconds.
	# The default is 900 (15 minutes).
	# fail_interval = 900
	#
	# The access will be re-enabled after n seconds after the lock out.
	# The value 0 has the same meaning as value `never` - the access
	# will not be re-enabled without resetting the faillock
	# entries by the `faillock` command.
	# The default is 600 (10 minutes).
	unlock_time = 86400
	#
	# Root account can become locked as well as regular accounts.
	# Enabled if option is present.
	even_deny_root
	#
	# This option implies the `even_deny_root` option.
	# Allow access after n seconds to root account after the
	# account is locked. In case the option is not specified
	# the value is the same as of the `unlock_time` option.
	# root_unlock_time = 900
	#
	# If a group name is specified with this option, members
	# of the group will be handled by this module the same as
	# the root account (the options `even_deny_root>` and
	# `root_unlock_time` will apply to them.
	# By default, the option is not set.
	# admin_group = <admin_group_name>
	EOF

	cp -r /etc/pam.d/common-auth /etc/pam.d/common-auth.backup
	tee /etc/pam.d/common-auth > /dev/null <<-EOF
	auth required pam_faillock.so preauth
	auth [success=1 default=bad] pam_unix.so
	auth [default=die] pam_faillock.so authfail
	auth optional pam_faillock.so authsucc
	EOF

	cp -r /etc/pam.d/common-account /etc/pam.d/common-account.backup
	tee /etc/pam.d/common-account > /dev/null <<-EOF
	account required pam_unix.so
	account required pam_faillock.so
	EOF

	# Enforce strong passwords
	tee /etc/security/pwquality.conf > /dev/null <<-EOF
	# added by hardened script
	# Configuration for systemwide password quality limits
	# Defaults:
	#
	# Number of characters in the new password that must not be present in the
	# old password.
	# difok = 1
	#
	# Minimum acceptable size for the new password (plus one if
	# credits are not disabled which is the default). (See pam_cracklib manual.)
	# Cannot be set to lower value than 6.
	minlen = 15
	#
	# The maximum credit for having digits in the new password. If less than 0
	# it is the minimum number of digits in the new password.
	dcredit = -1
	#
	# The maximum credit for having uppercase characters in the new password.
	# If less than 0 it is the minimum number of uppercase characters in the new
	# password.
	ucredit = -1
	#
	# The maximum credit for having lowercase characters in the new password.
	# If less than 0 it is the minimum number of lowercase characters in the new
	# password.
	lcredit = -1
	#
	# The maximum credit for having other characters in the new password.
	# If less than 0 it is the minimum number of other characters in the new
	# password.
	ocredit = -1
	#
	# The minimum number of required classes of characters for the new
	# password (digits, uppercase, lowercase, others).
	# minclass = 0
	#
	# The maximum number of allowed consecutive same characters in the new password.
	# The check is disabled if the value is 0.
	# maxrepeat = 0
	#
	# The maximum number of allowed consecutive characters of the same class in the
	# new password.
	# The check is disabled if the value is 0.
	# maxclassrepeat = 0
	#
	# Whether to check for the words from the passwd entry GECOS string of the user.
	# The check is enabled if the value is not 0.
	# gecoscheck = 0
	#
	# Whether to check for the words from the cracklib dictionary.
	# The check is enabled if the value is not 0.
	dictcheck = 1
	#
	# Whether to check if it contains the user name in some form.
	# The check is enabled if the value is not 0.
	usercheck = 1
	#
	# Length of substrings from the username to check for in the password
	# The check is enabled if the value is greater than 0 and usercheck is enabled.
	usersubstr = 5
	#
	# Whether the check is enforced by the PAM module and possibly other
	# applications.
	# The new password is rejected if it fails the check and the value is not 0.
	enforcing = 0
	#
	# Path to the cracklib dictionaries. Default is to use the cracklib default.
	# dictpath =
	#
	# Prompt user at most N times before returning with error. The default is 1.
	# retry = 3
	#
	# Enforces pwquality checks on the root user password.
	# Enabled if the option is present.
	enforce_for_root
	#
	# Skip testing the password quality for users that are not present in the
	# /etc/passwd file.
	# Enabled if the option is present.
	# local_users_only
	EOF

	print_success "Account lockout and password policy enforced."
}
functions_list="$functions_list Enforcing_account_lockout_and_password_policies"
