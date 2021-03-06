#!/usr/bin/env bash

DOTFILE_HOME=${DOTFILE_HOME:-$HOME/.dotfile.local}
DOTFILE_REPO=${DOTFILE_REPO:-"https://github.com/socheatsok78/.next.git"}

# string formatters
if [[ -t 1 ]]; then
    tty_escape() { printf "\033[%sm" "$1"; }
else
    tty_escape() { :; }
fi

tty_mkbold() { tty_escape "1;$1"; }
tty_underline="$(tty_escape "4;39")"
tty_blue="$(tty_mkbold 34)"
tty_red="$(tty_mkbold 31)"
tty_yellow="$(tty_mkbold 33)"
tty_bold="$(tty_mkbold 39)"
tty_reset="$(tty_escape 0)"

shell_join() {
    local arg
    printf "%s" "$1"
    shift
    for arg in "$@"; do
        printf " "
        printf "%s" "${arg// /\ }"
    done
}

chomp() {
    printf "%s" "${1/"$'\n'"/}"
}

ohai() {
    printf "${tty_blue}==>${tty_bold} %s${tty_reset}\n" "$(shell_join "$@")"
}

warn() {
    printf "${tty_yellow}Warning${tty_reset}: %s\n" "$(chomp "$1")"
}

error(){
    printf "${tty_red}Error${tty_reset}: %s\n" "$(chomp "$1")" >>/dev/stderr
}

abort() {
  printf "%s\n" "$1"
  exit 1
}

execute() {
  if ! "$@"; then
    abort "$(printf "Failed during: %s" "$(shell_join "$@")")"
  fi
}

####################################################################### traps
pre_install_trap() {
    echo
    warn "Aborted! Cleaning up..."
    if [ -d "$DOTFILE_HOME" ]; then
        rm -rf $DOTFILE_HOME
    fi
}

trap 'pre_install_trap' SIGINT

####################################################################### pre-flight
if [ -d "$DOTFILE_HOME" ]; then
    abort "Another version of dotfile was already installed on the system!"
fi

# First check if the OS is Linux.
if [[ "$(uname)" = "Linux" ]]; then
    abort "This dotfile is only available for macOS. Aborted!"
fi

# Check if Homebrew is installed
if [ ! `command -v brew` ]; then
    ohai "Installing Homebrew..."
    execute "sh" "-c" "$(curl -fsSL https://raw.githubusercontent.com/Linuxbrew/install/master/install.sh)"
fi

####################################################################### script
ohai "Preparing to install..."
git clone "$DOTFILE_REPO" "$DOTFILE_HOME" && cd "$DOTFILE_HOME" && ./setup.sh
