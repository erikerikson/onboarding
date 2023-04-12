#!/bin/bash

#######################
## Assumptions
##
## Running Ubuntu 22.04 LTS (or later?)

# Default Variable Values and Reporting
if [ -z ${SRC_ORG+x} ]; then
  SRC_ORG=loveworks
fi
if [ -z ${SRC_DIR+x} ]; then
  SRC_DIR=/src/$SRC_ORG
fi
if [ -z ${PROMPT+x} ]; then
  PROMPT='%(?.%F{green}√.%F{red}%?)%f %B%F{240}%1~%f%b | '
fi
if [ -z ${RPROMPT+x} ]; then
  RPROMPT='%*'
fi

set -euo pipefail

echo Running with...
echo \$NAME=$NAME
echo \$EMAIL=$EMAIL
echo \$SRC_DIR=$SRC_DIR
echo \$SRC_ORG=$SRC_ORG
echo \$PROMPT=$PROMPT
echo \$RPROMPT=$RPROMPT
echo \$SSO_START_URL=$SSO_START_URL

#####################
## Utility Functions
function idem() { # $1 must be side effect free && $2 must be a command (perhaps complex)
  ($1 &> /dev/null) || ($2)
}
function idem_cmd() { idem "command -v $1" "init_$1"; }
function init_dir() {
  sudo -s mkdir -p $1;
  sudo -s chown \$SUDO_UID:\$SUDO_GID $1;
}
function idem_dir() { idem "ls $1" "init_dir $(echo $1 | sed 's/-/_/g')"; }
function idem_git() { idem "ls $1" "git clone git@github.com:$SRC_ORG/$1.git"; }

#########################################
## Install and configure important tools
sudo apt update

function init_zsh() {
  sudo apt install zsh
  chsh -s $(which zsh)
  cp ./default.zshrc ~/.zshrc
  printf '%s\n' "" "export NAME='$NAME'" "export EMAIL=$EMAIL" >> ~/.zshrc
  printf '%s\n' "" "PROMPT='$PROMPT'" "RPROMPT=$RPROMPT" >> ~/.zshrc
}
idem_cmd zsh

function init_git() {
  sudo apt-get install git-all
  git config --global user.name "$NAME"
  git config --global user.email "$EMAIL"
}
idem_cmd git

idem "command -v curl" "sudo apt install curl"

function init_aws () {
  # install CLI
  mkdir ~/awstmp
  pushd ~/awstmp
  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
  unzip ./awscliv2.zip
  sudo ./aws/install
  popd
  rm -rf ~/awstmp
  # defaults for CLI auth
  mkdir ~/.aws
  echo "[profile default]" >> ~/.aws/config
  echo "sso_start_url = $SSO_START_URL" >> ~/.aws/config
  echo "sso_region = us-west-2" >> ~/.aws/config
  # trigger initial log in
  echo "This script will start the SSO flow for AWS, opening a browser."
  echo "Please..."
  echo "1. accept defaults as given"
  echo "2. select the 'sand' account"
  echo "3. choose your default role for the 'sand' account"
  echo "4. call this profile 'sand' so that documentation and scripts can use it"
  aws configure sso
  SAND_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text --profile sand)
  aws configure set role_arn arn:aws:iam::$SAND_ACCOUNT_ID:role/cicd --profile sand-cicd
  aws configure set source_profile sand --profile sand-cicd
}
idem_cmd aws

function init_nvm() {
  wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
  nvm install 16
  nvm use 16
  npm config set script-shell $(which zsh)
}
idem_cmd nvm

idem "command -v serverless" "npm i -g serverless"

idem "command -v code" "sudo snap install --classic code"

idem "command -v convert" "sudo apt install imagemagick"

idem "command -v chromium" "sudo apt-get install chromium-browser"

function init_google_chrome() {
  wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
  sudo apt install ./google-chrome-stable_current_amd64.deb
  rm ./google-chrome-stable_current_amd64.deb
}
idem_cmd google-chrome

################
## Get Source
echo "You are about to be challenged for GitHub's fingerprint.  Please copy the Ed25519 key from the following page"
echo https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/githubs-ssh-key-fingerprints

idem_dir $SRC_DIR
idem_dir $SRC_DIR/.vscode
idem "ls $SRC_DIR/.vscode/launch.json" "cp ./launch.json $SRC_DIR/.vscode/"
idem "ls $SRC_DIR/.vscode/settings.json" "cp ./settings.json $SRC_DIR/.vscode/"
pushd $SRC_DIR
  idem_git _
  idem_git loveworks
  idem_git onboarding
popd

# echo Wiki ... & # TODO - Knowledge Management
# echo Backlog ... & # TODO - Project Management
echo GitHub https://github.com/$SRC_ORG & # GitHub Org
xdg-open $SSO_START_URL # AWS Console
