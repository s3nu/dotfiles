#!/bin/sh

# nvm is installed by the Homebrew.
# "./node_modules/.bin". 
# For example: ./node_modules/.bin/webpack --config webpack.local.config.js

if test ! $(which nvm)
then
  echo "Installing a stable version of Node..."

  nvm install stable      # Install the latest stable version of node
  nvm use node            # Switch to the installed version
  nvm alias default node  # Use the stable version of node by default
fi

# All `npm install <pkg>` commands will pin to the version that was available at the time you run the command
npm config set save-exact = true

# Globally install with npm
# diff-so-fancy
# git-recent
# git-open

packages=(
    diff-so-fancy
    git-recent
    git-open
    gulp
    http-server
    servedir
    flow-bin
    flow-typed
    npm-check-updates
    webpack
    nodemon
    svgo
    yo
)

npm install -g "${packages[@]}"