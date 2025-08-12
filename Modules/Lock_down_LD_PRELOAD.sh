Lock_down_LD_PRELOAD(){
	_currnet_user="$SUDO_USER"
	print_info "Lock down LD_PRELOAD"
    # The below function fetches the minimium and maximium UIDS as configured in /etc/login.defs.
    # Any UIDs within this change are true user ids rather than system agents, and therefore
    # should be locked down. The user_string variable uses this fetched UID range to find all
    # existing users and their home directory along with formatting this data for later use.
    # The IFS line simply converts this data into a bash array.
    function user_list_lookup() {
        uid_min="$(grep -Po '^\s*UID_MIN\s+\K\d+' /etc/login.defs)"
        uid_max="$(grep -Po '^\s*UID_MAX\s+\K\d+' /etc/login.defs)"
        user_string="$(getent passwd | awk -F':' -v max="$uid_max" -v min="$uid_min" 'max >= $3 && $3 >= min {print $1}' | tr '\n' ',' | sed 's/,*$//')"
        IFS=',' read -ra user_list <<< "$user_string"
    }

    # $_currnet_user is the user who started the script instead of whichever authorized it via polkit
    # or the root home. From there this $USER_HOME uses getent to lookup their home directory to
    # later check if they have an existing .bashrc file.
    user_home="$(getent passwd "$_currnet_user" | cut -d: -f6)"
    if lsattr "$user_home/.bashrc" 2>/dev/null | awk '{print $1}' | grep -q 'i'; then
        pending_status="unlocked"
    else
        pending_status="locked"
    fi

    # Below variable is created to only call date once and use the same time across the script
    # despite execution time.
    current_time="$(date | tr ' ' '_')"

    if [[ "$pending_status" == "locked" ]]; then
        print_warning "This will change your ~/.bashrc, ~/.bash_profile, ~/.config/bash_completion, ~/.profile, ~/.bash_logout, ~/.bash_login, ~/.bashrc.d/, and ~/.config/environment.d/"
        print_warning "This is needed to ensure the mitigation (see LD_PRELOAD attacks) is effective."
        print_warning "This script will create backups of the old versions in ~/bash_env_files/$current_time."
    else
        print_warning " .bashrc, .bash_profile, and more will be unlocked and made editable by non-root users. This represents a security risk (see LD_PRELOAD attacks)"
    fi

    # shellcheck disable=SC2050
    print_info "Do you understand?"
    print_info 'Please type in "YES I UNDERSTAND" and press enter'
    read -r accept
    if [[ "$accept" != "YES I UNDERSTAND" ]]; then
		return
    fi
    
    # shellcheck disable=SC2050
    user_list_lookup
    print_info "Do you want this change to apply to all users (${user_list[*]})? [y/N]"
    print_info "Otherwise, it will only apply to the user who launched this script ($_currnet_user)."
    read -r reply
    if [[ "$reply" != [yY]* ]]; then
		user_list=("$_currnet_user")
    fi
    
    for user in "${user_list[@]}"; do
        print_info "Applying for user: $user"
        user_home="$(getent passwd "$user" | awk -F':' '{ print $6}')"
        [ -d "$user_home" ] || { print_info "Variable \$user_home for $user is somehow empty (check your getent passwd entries)"; print_error "safely exiting."; }

        BASH_ENV_FILES=(
            "$user_home/.bashrc"
            "$user_home/.bash_profile"
            "$user_home/.config/bash_completion"
            "$user_home/.profile"
            "$user_home/.bash_logout"
            "$user_home/.bash_login"
            "$user_home/.bashrc.d/"
            "$user_home/.config/environment.d/"
        )

        # Purpose of the below block is to actually lock or unlock the current selected user
        # across the configured BASH_ENV_FILES
        #    If the script is locking:
        #        to copy the old env files and directories to folder with the time appended to its name
        #        remove immutability (to allow the script to overwrite any existing immutable environment files)
        #        create default or blank copies (deleting the old versions)
        #        add immutability

        if [[ "$pending_status" == "locked" ]]; then
            backup_dest="$user_home/bash_env_files/$current_time/"
            mkdir -p "$backup_dest"

            for file in "${BASH_ENV_FILES[@]}"; do
                # skel_file converts "$user_home/.bashrc" to ".bashrc"
                skel_file="${file#"${user_home}/"}"
                if [ ! -f "$file" ] && [ ! -d "$file" ] && [ -e "$file" ]; then
                    print_info "Special file detected on absolute filepath ($file) from BASH_ENV_FILES. It will not be modified."
                elif [ -f "$file" ]; then
                    chattr -i "$file"
                    rsync -a --mkpath "$file" "$backup_dest$skel_file"
                    rm "$file"
                elif [ -d "$file" ]; then
                    chattr -R -i "$file"
                    rsync -a --mkpath "$file" "$backup_dest$skel_file"
                    rm -r "$file"
                fi

                # Now we create new empty/default files and directories
                if [ "${file: -1}" == "/" ]; then
                    install -D -d -o "$user" -g "$user" -m 700 "$file"
                    chattr +i -R "$file"
                elif [ -f "/etc/skel/$skel_file" ]; then
                    install -D -o "$user" -g "$user" -m 700 "/etc/skel/$skel_file" "$file"
                    chattr +i "$file"
                else
                    install -D -o "$user" -g "$user" -m 700 /dev/null "$file"
                    chattr +i "$file"
                fi
            done

            chmod -R 700 "$user_home/bash_env_files"
            chown -R "$user:" "$user_home/bash_env_files"
        else
            for file in "${BASH_ENV_FILES[@]}"; do
                if [ ! -f "$file" ] && [ ! -d "$file" ] && [ -e "$file" ]; then
                    print_info "Special file detected on absolute filepath ($file) from BASH_ENV_FILES. It will not be modified."
                elif [ -f "$file" ]; then
                    chattr -i "$file"
                elif [ -d "$file" ]; then
                    chattr -R -i "$file"
                fi
            done
        fi
    done

    print_info "${user_list[@]} $pending_status."
    print_success "NOTE: until a reboot, any process with an open file descriptor will continue to have the access they had before this script was run."
}
functions_list="$functions_list Lock_down_LD_PRELOAD"
