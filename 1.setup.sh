#!/bin/bash

#######################
## Assumptions
##
## Running Ubuntu 22.04 LTS (or later?)

set -euo pipefail

# Default Variable Values and Reporting
if [ -z ${SRC_DIR+x} ]; then
    SRC_DIR=~/src
fi
if [ -z ${SRC_ORG+x} ]; then
    SRC_ORG=erikerikson
fi
if [ -z ${PROMPT+x} ]; then
    PROMPT='%(?.%F{green}√.%F{red}%?)%f %B%F{240}%1~%f%b | '
fi
if [ -z ${RPROMPT+x} ]; then
    RPROMPT='%*'
fi
echo Running with...
echo \$NAME=$NAME
echo \$EMAIL=$EMAIL
echo \$SRC_DIR=$SRC_DIR
echo \$SRC_ORG=$SRC_ORG
echo \$PROMPT=$PROMPT
echo \$RPROMPT=$RPROMPT

#####################
## Utility Functions
function idem() { # $1 must be side effect free && $2 must be a command (perhaps complex)
    ($1 &> /dev/null) || ($2)
}
function idem_cmd() { idem "command -v $1" "init_$1"; }
function idem_dir() { idem "ls $SRC_DIR" "mkdir $SRC_DIR"; }
function idem_git() { idem "ls $1" "git clone git@github.com:$SRC_ORG/$1.git" }

#########################################
## Install and configure important tools
sudo apt update

function init_zsh() {
    sudo apt install zsh
    chsh -s $(which zsh)
    cp ./default.zshrc ~/.zshrc
    printf '%s\n' "" "NAME='$NAME'" "EMAIL=$EMAIL" >> ~/.zshrc
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
  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
  unzip awscliv2.zip
  sudo ./aws/install
  echo "This script will start the SSO flow for AWS, opening a browser."
  echo "Please select your default role for the `sand` account."
  echo "This will be your default AWS credential."
  aws configure sso --profile sand
}
idem_cmd aws

function init_nvm() {
    wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh || bash
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
    nvm install 18
    nvm use 18
}
idem_cmd nvm

idem "command -v code" "sudo snap install --classic code"

idem "command -v chromium" "sudo apt-get install chromium-browser"

function init_chrome() {
  wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
  sudo apt install ./google-chrome-stable_current_amd64.deb
}
idem_cmd chrome

################
## Get Source
echo "You are about to be challenged for GitHub's fingerprint.  Please copy the Ed25519 key from the page about to openned in your browser"
xdg-open https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/githubs-ssh-key-fingerprints &

idem_dir $SRC_DIR
pushd $SRC_DIR
    idem_git onboarding
    idem_git aws
popd src

# xdg-open ... & # TODO - Knowledge Management
# xdg-open ... & # TODO - Project Management
xdg-open https://github.com/$SRC_ORG & # GitHub Org
# xdg-open ... & # TODO - AWS Console
