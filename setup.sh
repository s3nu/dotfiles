#!/bin/bash
# This symlinks all the dotfiles (and .atom/) to ~/
# It also symlinks ~/bin for easy updating

#
# Utils
#
answer_is_yes() {
  [[ "$REPLY" =~ ^[Yy]$ ]] \
    && return 0 \
    || return 1
}

ask() {
  print_question "$1"
  read
}

ask_for_confirmation() {
  print_question "$1 (y/n) "
  read -n 1
  printf "\n"
}

ask_for_sudo() {
  sudo -v   # Ask for the sudo password
  while true; do
    sudo -n true
    sleep 60
    kill -0 "$$" || exit
  done &> /dev/null &
}

cmd_exists() {
  [ -x "$(command -v "$1")" ] \
    && printf 0 \
    || printf 1
}

execute() {
  $1 &> /dev/null
  print_result $? "${2:-$1}"
}

get_answer() {
  printf "$REPLY"
}

get_os() {
  declare -r OS_NAME="$(uname -s)"
  local os=""

  if [ "$OS_NAME" == "Darwin" ]; then
    os="osx"
  elif [ "$OS_NAME" == "Linux" ] && [ -e "/etc/lsb-release" ]; then
    os="ubuntu"
  fi

  printf "%s" "$os"

}

is_git_repository() {
  [ "$(git rev-parse &>/dev/null; printf $?)" -eq 0 ] \
    && return 0 \
    || return 1
}

mkd() {
  if [ -n "$1" ]; then
    if [ -e "$1" ]; then
      if [ ! -d "$1" ]; then
        print_error "$1 - a file with the same name already exists!"
      else
        print_success "$1"
      fi
    else
      execute "mkdir -p $1" "$1"
    fi
  fi
}

print_error() {
  printf "\e[0;31m  [✖] $1 $2\e[0m\n"   # Print output in red
}

print_info() {
  printf "\n\e[0;35m $1\e[0m\n\n"       # Print output in purple
}

print_question() {
  printf "\e[0;33m  [?] $1\e[0m"        # Print output in yellow
}

print_result() {
  [ $1 -eq 0 ] \
    && print_success "$2" \
    || print_error "$2"

  [ "$3" == "true" ] && [ $1 -ne 0 ] \
    && exit
}

print_success() {
  printf "\e[0;32m  [✔] $1\e[0m\n"      # Print output in green
}

while true; do
  read -p "Warning: this will overwrite your current dotfiles. Continue? [y/n] " yn
  case $yn in
    [Yy]* ) break;;
    [Nn]* ) exit;;
    * ) echo "Please answer yes or no.";;
  esac
done

# Get the dotfiles directory's absolute path
SCRIPT_DIR="$(cd "$(dirname "$0")"; pwd -P)"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"


dir=~/.dotfiles                        # dotfiles directory
dir_backup=~/.dotfiles_old             # old dotfiles backup directory

# Get current dir (so run this script from anywhere)
export DOTFILES_DIR
DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Create dotfiles_old in homedir
echo -n "Creating $dir_backup for backup of any existing dotfiles in ~..."
mkdir -p $dir_backup
echo "done"

# Change to the dotfiles directory
echo -n "Changing to the $dir directory..."
cd $dir
echo "done"


# symlink code
# echo -n "Copying Atom settings.."   # Atom editor settings
# mv -f ~/.atom ~/.dotfiles_old/
# ln -s $HOME/.dotfiles/programs/atom ~/.atom
# echo "done"


declare -a FILES_TO_SYMLINK=(
  # 'programs/vim'
  'programs/zsh'
  'shell/shell_config'
  'shell/shell_aliases'
  'shell/shell_exports'
  'shell/shell_functions'
  'shell/zshrc'
  # 'shell/ackrc'
  'shell/curlrc'
  'shell/editorconfig'
  # 'shell/vimrc'
  'git/gitattributes'
  'git/gitconfig'
  'git/gitignore'
  'git/gitignore_global'
  'git/hgignore'
)

# FILES_TO_SYMLINK="$FILES_TO_SYMLINK .vim bin" # add in vim and the binaries

# Move any existing dotfiles in homedir to dotfiles_old directory, then create symlinks from the homedir to any files in the ~/dotfiles directory specified in $files
for i in ${FILES_TO_SYMLINK[@]}; do
  echo "Moving any existing dotfiles from ~ to $dir_backup"
  mv ~/.${i##*/} ~/.dotfiles_old/
done

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
main() {
  local i=''
  local sourceFile=''
  local targetFile=''
  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  for i in ${FILES_TO_SYMLINK[@]}; do

    sourceFile="$(pwd)/$i"
    targetFile="$HOME/.$(printf "%s" "$i" | sed "s/.*\/\(.*\)/\1/g")"

    if [ ! -e "$targetFile" ]; then
      execute "ln -fs $sourceFile $targetFile" "$targetFile → $sourceFile"
    elif [ "$(readlink "$targetFile")" == "$sourceFile" ]; then
      print_success "$targetFile → $sourceFile"
    else
      ask_for_confirmation "'$targetFile' already exists, do you want to overwrite it?"
      if answer_is_yes; then
        rm -rf "$targetFile"
        execute "ln -fs $sourceFile $targetFile" "$targetFile → $sourceFile"
      else
        print_error "$targetFile → $sourceFile"
      fi
    fi
  done
  unset FILES_TO_SYMLINK

#Disabled Bindary Files for Now 
  # Copy binaries
  #ln -fs $HOME/dotfiles/bin $HOME

  # declare -a BINARIES=(
    # 'crlf'
    # 'dups'
    # 'git-delete-merged-branches'
    # 'git-loglive'
    # 'img-ascii-diff'
    # 'nyan'
    # 'passive'
    # 'proofread'
    # 'ssh-key'
    # 'weasel'
  # )

  # for i in ${BINARIES[@]}; do
  #   echo "Changing access permissions for binary script :: ${i##*/}"
  #   chmod +rwx $HOME/bin/${i##*/}
  # done

  # unset BINARIES
#Disabled Bindary Files for Now
}   #End Main Function

install_zsh () {  #Function to install zsh in parrallel with bash
  # Test to see if zshell is installed.  If it is:
  if [ -f /bin/zsh -o -f /usr/bin/zsh ]; then
    # Install Oh My Zsh if it isn't already present
    if [[ ! -d $dir/oh-my-zsh/ ]]; then
      sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
    fi
    # Set the default shell to zsh if it isn't currently set to zsh
    if [[ ! $(echo $SHELL) == $(which zsh) ]]; then
      chsh -s $(which zsh)
    fi
  else
    # If zsh isn't installed, get the platform of the current machine
    platform=$(uname);
    # If the platform is Linux, try an apt-get to install zsh and then recurse
    if [[ $platform == 'Linux' ]]; then
      if [[ -f /etc/redhat-release ]]; then
        sudo yum install zsh
        install_zsh
      fi
      if [[ -f /etc/debian_version ]]; then
        sudo apt-get install zsh
        install_zsh
      fi
    # If the platform is OS X, tell the user to install zsh :)
    elif [[ $platform == 'Darwin' ]]; then
      echo "We'll install zsh, then re-run this script!"
      brew install zsh
      exit
    fi
  fi
}

####  Duplicate install   ####
# Package managers & packages
# . "$DOTFILES_DIR/install/brew.sh"
# . "$DOTFILES_DIR/install/npm.sh"
# if [ "$(uname)" == "Darwin" ]; then
    # . "$DOTFILES_DIR/install/brew-cask.sh"
# fi
####  Duplicate install   ####

###############################################################################
# Fuction Calls                                                              #
###############################################################################
main
#install_zsh  #Disabled

###############################################################################
# Zsh                                                                         #
###############################################################################
# Install Zsh settings
ln -s ~/.dotfiles/zsh/themes/anahit.zsh-theme $HOME/.oh-my-zsh/themes

###############################################################################
# Terminal & iTerm 2                                                          #
###############################################################################
# Only use UTF-8 in Terminal.app
defaults write com.apple.terminal StringEncodings -array 4

# Install the iTerm and Terminal
open "${DOTFILES_DIR}/programs/iterm/themes/anahit_custom.itermcolors"
open "${DOTFILES_DIR}/programs/terminal/anahit_custom.terminal"

# Don’t display the annoying prompt when quitting iTerm
defaults write com.googlecode.iterm2 PromptOnQuit -bool false

source ~/.zshrc;          # Reload zsh settings


