#!/bin/bash

echo -e "\n\n\033[35m\033[1mcw setup script lite\nmod 2024-10-28\nfrom curl -fLks https://raw.githubusercontent.com/cuteweeds/setup-mac/refs/heads/lite/setup.sh\033[0m"

# Check for git, exit if it's missing
if test ! $(which git); then
  echo -e "\nGit not found. Install it whatever way is best and re-run this script."
  exit
fi

## Check for xcode-select, Install if we don't have it
if test ! $(which xcode-select); then
  echo -e "\nInstalling xcode-stuff"
  xcode-select --install
fi

# Install homebrew if we don't have it
if test ! $(which brew); then
  echo -e "\nInstalling homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

brew update
brew upgrade

brew install --cask git-credential-manager
brew install gpg
brew install gh
brew cleanup

mkdir -p ~/.gnupg
curl -o ~/.gnupg/remu.gpg https://raw.githubusercontent.com/cuteweeds/setup-mac/refs/heads/lite/remu.gpg

echo -e "\nLog into git"
#/usr/local/bin/gh auth login

task="fetching dotfiles..."
echo -e "\033[36m\n$task\033[0m"
user="cuteweeds@gmail.com"
password=$(gpg --decrypt $HOME/.gnupg/remu.gpg)
cd $HOME
git clone --bare https://cuteweeds:$password@github.com/cuteweeds/.dotfiles $HOME/.dotfiles

task="writing to .gitignore..."
echo -e "\033[36m\n$task"
echo ".dotfiles" >> .gitignore

task="backing up existing config files"
echo "$task"
mkdir -p $HOME/.config-backup/.config/gh && mv .config/gh/* $HOME/.config-backup/.config/gh
mkdir -p $HOME/.config-backup &&  git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME checkout 2>&1 | grep -v "error:" | grep -v "Please move or remove them before you switch branches" | egrep '.?\s+[^\s]' | sed 's/^.//' |  awk {'print $1'} | xargs -I{} mv {} $HOME/.config-backup/{}

task="checking out .dotfiles"
echo -e "\033[36m$task"
git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME checkout

task="turning off untracked-file messages"
echo "$task"
git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME config --local status.showUntrackedFiles no 

#echo "writing to .zshrc"
#echo "alias dotfiles=\"/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME\"" >> $HOME/.zshrc
#echo "alias dot=\"/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME\"" >> $HOME/.zshrc

echo "setting aliases"
alias dotfiles="/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME"
alias dot="/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME"

echo -e "checking status\n"
git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME status

echo -e "\nIf you see \"On branch <name>\" above, dotfiles installed correctly."
echo -e "\n\033[32m\033[1mUpdating dotfiles"
echo -e  "\n\033[1m\033[36mUse 'dot' instead of 'git' for dotfile maintenance\033[0m\033[36m\n- dot status\n- dot add <file>\n- dot push\n- dotcetera...\033[0m\n"

echo -e "\n\033[1m\033[36mPackages to install\033[0m\n"
cat Brewfile

brew bundle install
brew cleanup

# Give userscripts exec permissions
cd $HOME/.userscripts
ls | while read line; do chmod u+x $line; done
cd $HOME

# Give runafter scripts exec permissions and then run them (.myprefs/load.sh should be LAST):
runafterlist="\
$HOME/.liteinstalls/install.sh,\
$HOME/.ssh/decrypt-keys.sh"\
$HOME/.myprefs/load.sh"
echo "$runafterlist" | tr ',' '\n' | while read line; do dir=$(dirname $line); file=$(basename $line); cd $dir; pwd; chmod u+x $file; bash $file; cd ~/; done
