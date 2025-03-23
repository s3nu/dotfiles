#!/usr/bin/env bash

echo "Do not run this script in one go. Hit Ctrl-C NOW"
read -n 1

sudo -v 	#Ask for the administrator password upfront

###############################################################################
# ========= Xcode ==========													  #
###############################################################################
#	xcode-select --install 		#Install Command Line Tools
#	sudo xcodebuild -license	#Agree to the XCode license

if ! xcode-select --print-path &> /dev/null; then
  xcode-select --install &> /dev/null	#install cli tools if needed

  until xcode-select --print-path &> /dev/null; do
    sleep 5
  done

  print_result $? 'Install XCode Command Line Tools'
  
  sudo xcode-select -switch /Applications/Xcode.app/Contents/Developer
  print_result $? 'Make "xcode-select" developer directory point to Xcode'

  sudo xcodebuild -license #Accept User Agreement
  print_result $? 'Agree with the XCode Command Line Tools licence'
fi

###############################################################################
# ========= Brew ==========													  #
###############################################################################
# Check for Homebrew and install it if missing + list of dev packages
if test ! $(which brew)
then
  echo "Installing Homebrew..."
  ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

brew update     # Latest updates and upgrades
brew upgrade 		# Latest updates and upgrades

# Install Brew formulae and apps via Cask
brew bundle --file=programs/brew/anahit_brewfile
# chmod u+x /programs/brew/brew.sh
# /programs/brew/brew.sh
#	$HOME/dotfiles/install/brew-cask.sh

brew cleanup	#Remove Depracted formulas
brew doctor   #Check for issues

###############################################################################
# ========= Node ==========													  #
###############################################################################
#	$HOME/dotfiles/install/npm.sh
#	npm install -g git-open
#	npm install -g trash-cli

###############################################################################
# ========= Bash ==========													  #
###############################################################################
#Set Zsh to default shell
chsh -s /opt/homebrew/bin/zsh 
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

###############################################################################
# =========== Vim =============												  #
###############################################################################
# Install vim-plug plugin manager
#curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

###############################################################################
# =========== Composer =============										  #
###############################################################################
# Install composer
#curl -sS https://getcomposer.org/installer | php -- --install-dir=$HOME/bin --filename=composer

###############################################################################
# Atom                                                                        #
###############################################################################
# ln -s /Applications/Atom.app/Contents/Resources/app/atom.sh /usr/local/bin/atom
# cp -r programs/atom/packages.list $HOME/.atom  # Copy over Atom configs
# apm list --installed --bare - get a list of installed packages # List community packages
# apm install --packages-file $HOME/.atom/packages.list # Install community packages
###############################################################################
# OSX defaults                                                                #
###############################################################################
#sh osx/set-defaults.sh

###############################################################################
# =========== Custom =============										      #
###############################################################################
# sudo easy_install Pygments #For cat alias (syntax highlighted cat)

###############################################################################
# Symlinks to link dotfiles into ~/                                           #
###############################################################################
./setup.sh 		#Run custom setup script


