#!/bin/bash

echo -e "\n\n\033[35m\033[1mcw setup script lite\nupdated 2024-10-28\nfrom curl -fLks https://raw.githubusercontent.com/cuteweeds/setup-mac/refs/heads/lite/setup.sh\033[0m"

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

# Make sure credentials packages are installed
if test ! $(which git-credential-manager); then
  echo -e "\nInstalling git-credential-manager"
  brew install --cask git-credential-manager
fi
if test ! $(which gpg); then
  echo -e "\nInstalling gpg"
  brew install gpg
fi
if test ! $(which gh); then
  echo -e "\nInstalling gh"
  brew install gh
fi

brew cleanup

#echo -e "\nLog into git"
#/usr/local/bin/gh auth login

mkdir -p $HOME/.gnupg
echo "setting $HOME/.gnupg/gpg-agent.conf..."
touch $HOME/.gnupg/gpg-agent.conf
echo "default-cache-ttl 1" > $HOME/.gnupg/gpg-agent.conf
echo "max-cache-ttl 1" >> $HOME/.gnupg/gpg-agent.conf
echo "sending RELOADAGENT to gpg-connect-agent..."
echo RELOADAGENT | gpg-connect-agent

task="fetching dotfiles..."
echo -e "\033[36m\n$task\033[0m"
export GPG_TTY=$(tty)
mkdir -p $HOME/setup-mac
curl 'https://raw.githubusercontent.com/cuteweeds/setup-mac/refs/heads/lite/remu.gpg' > $HOME/setup-mac/remu.gpg
curl 'https://raw.githubusercontent.com/cuteweeds/setup-mac/refs/heads/lite/remu.sh' > $HOME/setup-mac/remu.sh
cd $HOME/setup-mac
chmod u+x remu.sh

cd $HOME
user="cuteweeds"
password=$(gpg --decrypt --interactive --verbose setup-mac/remu.gpg)
git clone --bare -b lite https://$user:$password@github.com/cuteweeds/.dotfiles $HOME/.dotfiles

task="writing to .gitignore..."
echo -e "\033[36m\n$task"
echo ".dotfiles" >> .gitignore

task="backing up existing config files"
echo "$task"
mkdir -p $HOME/setup-mac/config-backup/.config/gh && mv $HOME/.config/gh/* $HOME/setup-mac/config-backup/.config/gh
mkdir -p $HOME/setup-mac/config-backup/.gnupg && mv $HOME/.gnugp/* $HOME/setup-mac/config-backup/.gnupg
mkdir -p $HOME/setup-mac/config-backup/.liteinstalls && mv $HOME/.liteinstalls/* $HOME/setup-mac/config-backup/.liteinstalls
mkdir -p $HOME/setup-mac/config-backup/.myprefs && mv $HOME/.myprefs/* $HOME/setup-mac/config-backup/.myprefs
mkdir -p $HOME/setup-mac/config-backup/.ssh && mv $HOME/.ssh/* $HOME/setup-mac/config-backup/.ssh
mkdir -p $HOME/setup-mac/config-backup/.userscripts && mv $HOME/.userscripts/* $HOME/setup-mac/config-backup/.userscripts
mv $HOME/.gitconfig/* $HOME/setup-mac/config-backup/
mv $HOME/.gitignore/* $HOME/setup-mac/config-backup/
mv $HOME/.runafter/* $HOME/setup-mac/config-backup/
mv $HOME/.stow-global-ignore/* $HOME/setup-mac/config-backup/
mv $HOME/.zshrc/* $HOME/setup-mac/config-backup/
mv $HOME/.Brewfile/* $HOME/setup-mac/config-backup/
mv $HOME/.README.md/* $HOME/setup-mac/config-backup/
git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME checkout 2>&1 | grep -v "error:" | grep -v "Please move or remove them before you switch branches" | egrep '.?\s+[^\s]' | sed 's/^.//' |  awk {'print $1'} | xargs -I{} mv {} $HOME/.config-backup/{}

task="checking out .dotfiles"
echo -e "\033[36m$task"
git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME checkout lite

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
