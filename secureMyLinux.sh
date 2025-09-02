#!/usr/bin/env bash
#todo: Provide system auditing tooling to verify the status of system hardening and provide users with suggestions.
set -euo pipefail

__opt="${1:-}"
installation_mode="${2:-}"
if [ "$installation_mode" != "ask_before_install" ];then
	bin_path="${2:-/usr/local/bin}"
else
	bin_path="${3:-/usr/local/bin}"
fi

RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
CYAN="\033[0;36m"
RESET="\033[0m"

grub_update=false

current_path="$(realpath "$0")"
repo_dir="$(dirname "$current_path")"

functions_list=""

print_info() {
	printf "${CYAN}【 💡 】%s${RESET}\n" "$1"
}

print_success() {
	printf "${GREEN}【 ✅ 】%s${RESET}\n" "$1"
}

print_warning() {
	printf "${YELLOW}【 ⚠️ 】%s${RESET}\n" "$1"
}

print_error() {
	printf "${RED}【 ⛔ 】%s${RESET}\n" "$1" >&2
	exit 1
}

print_error_without_exit() {
	printf "${RED}【 ⛔ 】%s${RESET}\n" "$1" >&2
}

ask_first() {
    printf '%s [%s]: ' "$1" "$2"
    stty -icanon
    answer=$(dd ibs=1 count=1 2>/dev/null)
    stty icanon
    printf '\n'
    case "$answer" in $3) return 0; esac; return 1
}

usage() {
	printf "${YELLOW}Usage:${RESET} %s [--update | --full | --help] [ask_before_install]:\n" "$(basename "$0")"
	printf "  --list		List of all modules.\n"
	printf "  --menu		show fzf menu to pick hardening module.\n"
	printf "  --update   	Pull latest changes from the repository.\n"
	printf "  --full-safe   Run full security hardening in unsafe mode.\n"
	printf "  --full	 	Run full security hardening in safe mode.\n"
	printf "  --help	 	Show this help message.\n"
}

list_modules() {
	printf "${YELLOW}List of all modules:${RESET} %s:\n" "$(basename "$0")"
	cd "${repo_dir}/Modules" && ls | sed 's/.sh//g' | column
}

menu_modules(){
	printf "${YELLOW}List of all modules:${RESET} %s:\n" "$(basename "$0")"
	selected_module="$(cd "${repo_dir}/Modules" && ls | sed 's/.sh//g' | fzf --with-nth=1,2 --delimiter='\t' --prompt='Select module: ' | cut -f1)"

    if [ -n "$selected_module" ]; then
        run_module "$selected_module"
    else
        print_info "No module selected."
    fi
}

update_script() {
	if [ -d "$repo_dir/.git" ]; then
		print_info "Repository found. Updating..."
		if git -C "$repo_dir" pull --quiet; then
			print_success "Repository updated successfully."
		else
			print_error "Failed to update repository."
		fi
	else
		print_error "Not a git repository: $repo_dir/.git not found."
	fi
}

run_module(){
	module_name="${1:-}"
	print_info "Running module: ${module_name} ..."
	module_file="$repo_dir/Modules/${module_name}.sh"
	[ -f "$module_file" ] && source "$module_file" || print_error_without_exit "Unknown module: $module_name"; list_modules; exit 1
	$functions_list || print_error "failed to run $functions_list"
}

init_script(){
	print_info "Debian Hardening Script Starting..."
	# Ensure script is run as root
	if [ "${EUID:-$(id -u)}" -ne 0 ]; then
  		print_error "Please run as root"
	fi
	print_info "Running full system hardening in safe mode..."
	print_info "Updating system..."
	apt update && apt upgrade -y

}

_full(){	
	for file in "$repo_dir/Modes/Full"/*.sh; do
  		[ -f "$file" ] && source "$file" || print_error "failed to source $file"
	done
	for function2run in $functions_list; do
		if [ "$installation_mode" = "ask_before_install"];then
			ask_first "install module ${function2run} ?" "y/n" "y|Y" && ( $function2run || print_error "failed to run $function2run" )
		else
			$function2run || print_error "failed to run $function2run"
		fi
	done
	print_success "Hardening complete."
}

_safe_full(){	
	for file in "$repo_dir/Modes/Full"/*.sh; do
  		[ -f "$file" ] && source "$file" || print_error "failed to source $file"
	done
	for function2run in $functions_list; do
  		if [ "$installation_mode" = "ask_before_install"];then
			ask_first "install module ${function2run} ?" "y/n" "y|Y" && ( $function2run || print_error "failed to run $function2run" )
		else
			$function2run || print_error "failed to run $function2run"
		fi
	done
	print_success "Hardening complete."
}

sread() {
    printf '%s: ' "$2"

    # Disable terminal printing while the user inputs their
    # password. POSIX 'read' has no '-s' flag which would
    # effectively do the same thing.
    stty -echo
    read -r "$1"
    stty echo

    printf '\n'
}

case "$__opt" in
	--list)			list_modules && exit ;;
	--menu)			menu_modules ;;
	--update)		update_script ;;
	--full-safe)   	_safe_full ;;
	--full)		   	_full ;;
	--help|-h|"")	usage ;;
	*) 				run_module "$__opt" ;;
esac
