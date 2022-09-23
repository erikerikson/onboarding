#!/bin/bash

#######################
## Assumptions
##
## Running Ubuntu 22.04 LTS (or later?)

set -euo pipefail

echo Running with \$NAME=$NAME
echo Running with \$EMAIL=$EMAIL

echo \nYour Public Key will be printed to the console, copy that or the entire contents of ~/.ssh/id_ed25519.pub
echo A GitHub page for adding an ssh key will be opened for you add it to GitHub

ssh-keygen -t ed25519 -C "$EMAIL"
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
cat ~/.ssh/id_ed25519.pub

xdg-open https://github.com/settings/ssh/new &
