#!/bin/zsh

# Log file
timestamp=$(date +%s)
logFile="./my-mac-setup-$timestamp.log"

# if true is passed in, reinstall things
reinstall=$1

beginInstallation() {
  printf "Starting installation for %s..." "$1" | tee -a |  tee -a "$logFile"
}

installComplete() {
  printf "Installation complete for %s.\n\n\n" "$1" | tee -a "$logFile"
}


#List  of applications to install via brew
declare -a brewApps=("zlib" "pkg-config" "git" "github/gh/gh" "gpg" "nvm" "wget" "starship" "pyenv" "zplug" "composer" "go" "php" "php@7.4")

#List of applications installed via brew cask
declare -a brewCaskApps=("postman" "phpmon" "anaconda" "visual-studio-code-insiders" "iterm2" "figma" "flux" "font-fira-code" "google-chrome" "google-chrome-canary" "ngrok" "postman" "sketch" "slack" "visual-studio-code-insiders" "vlc")

# Global node packages to install
declare -a globalNodePackages=("npm@latest" "yarn" "yo")

#List of application to start right away
declare -a appsToStartRightAway=("Flux")

echo "Installing command line tools" | tee -a "$logFile"
xcode-select --install

command -v brew >/dev/null 2>&1 || {
  beginInstallation "Homebrew"

  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  installComplete "Homebrew"

  beginInstallation "Homebrew Cask"
  brew tap caskroom/cask
  installComplete "Homebrew Cask"
} | tee -a "$logFile"

echo "Setting up some brew tap stuff for fonts and some applications" | tee -a "$logFile"

brew tap nicoverbruggen/homebrew-cask | tee -a "$logFile"
brew tap homebrew/cask-versions | tee -a "$logFile"
brew tap homebrew/cask-fonts | tee -a "$logFile"
brew tap homebrew/services | tee -a "$logFile"

echo "Finished setting up some brew tap stuff for fonts and some applications" | tee -a "$logFile"



for appName in "${brewApps[@]}"
do
  beginInstallation "$appName" | tee -a "$logFile"

  if [ "$reinstall" = true ]; then
    brew reinstall "$appName" | tee -a "$logFile"
  else
    brew install "$appName" | tee -a "$logFile"
  fi

  installComplete "$appName" | tee -a "$logFile"
done

for appName in "${brewCaskApps[@]}"
do
  beginInstallation "$appName" | tee -a "$logFile"

  if [ "$reinstall" = true ]; then
    brew reinstall --cask "$appName" | tee -a "$logFile"
  else
    brew install --cask "$appName" | tee -a "$logFile"
  fi

  installComplete "$appName" | tee -a "$logFile"
done

beginInstallation "Setting up node.js" | tee -a "$logFile"

export NVM_DIR="$HOME/.nvm"
mkdir "$NVM_DIR"

[ -s "/usr/local/opt/nvm/nvm.sh" ] && . "/usr/local/opt/nvm/nvm.sh"  # This loads nvm

echo "Installing LTS version of node."
nvm install --lts
nvm alias default "lts/*"
nvm use default
installComplete "Finished installing node.js." | tee -a "$logFile"

beginInstallation "Installing global node packages" | tee -a "$logFile"
npm i -g "${globalNodePackages[@]}" | tee -a "$logFile"
installComplete "Finished installing global node packages." | tee -a "$logFile"

echo "Creating .zshrc file" | tee -a "$logFile"
touch ~/.zshrc | tee -a "$logFile"



beginInstallation " Install laravel/valet"
composer global require laravel/valet
valet install
installComplete " Finished installing valet"

# install xdebug
beginInstallation " Xdebug"
pecl install xdebug
installComplete " Finished installing Xdebug"



echo "Testing zsh prompt" | tee -a "$logFile"
zsh | tee -a "$logFile"

echo "Starting applications that are used for the Desktop" | tee -a "$logFile"
for appName in "${appsToStartRightAway[@]}"
do
  echo "Starting $appName..." | tee -a "$logFile"
  open -a "$appName" | tee -a "$logFile"
done

echo "A setup log is available at $logFile."


#export NVM_DIR=~/.nvm
#source $(brew --prefix nvm)/nvm.sh
