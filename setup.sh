#!/bin/bash

echo -e "\n\n\033[35m\033[1mcw setup script lite\nupdated 2024-10-28 (texan)\nfrom curl -fLks https://raw.githubusercontent.com/cuteweeds/setup-mac/refs/heads/lite/setup.sh\033[0m"

# Check for git, exit if it's missing
if test ! $(which git); then
  echo -e "\nGit not found. Install it whatever way is best and re-run this script."
  exit
fi

## Check for xcode-select, Install if we don't have it
if test ! $(which xcode-select); then
  echo -e "\n\033[35mInstalling xcode-stuff\033[0m"
  xcode-select --install
fi

# Install homebrew if we don't have it
if test ! $(which brew); then
  echo -e "\n\033[35mInstalling homebrew...\033[0m"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

brew update
brew upgrade

# Make sure credentials packages are installed
if test ! $(which git-credential-manager); then
  echo -e "\n\033[35mInstalling git-credential-manager\033[0m"
  brew install --cask git-credential-manager
fi
if test ! $(which gpg); then
  echo -e "\n\033[35mInstalling gpg\033[0m"
  brew install gpg
fi
if test ! $(which gh); then
  echo -e "\n\033[35mInstalling gh\033[0m"
  brew install gh
fi

brew cleanup

#echo -e "\nLog into git"
#/usr/local/bin/gh auth login

# Credentials checks
if [[ -f "$HOME/setup-mac/repo_key" ]]; then
    echo "Private repo key found:"
    password=$(cat $HOME/setup-mac/repo_key)
    echo $password
else
    # Try to download and decypt repo key. Resets gpg-agent.
    echo -e "\033[1mPrivate repo key not yet installed. Attempting to create.\033[0m"
    mkdir -p $HOME/.gnupg
    
    # To fix the " gpg: WARNING: unsafe permissions on homedir '/home/path/to/user/.gnupg' " error
    # Make sure that the .gnupg directory and its contents is accessibile by your user.
    echo -e "\033[35msetting .gnupg/ permissions...\033[0m"
    chown -R $(whoami) $HOME/.gnupg/

    # Also correct the permissions and access rights on the directory
    chmod 600 $HOME/.gnupg/*
    chmod 700 $HOME/.gnupg
    export GPG_TTY=$(tty)
    
    echo -e "\033[35msetting $HOME/.gnupg/gpg-agent.conf...\033[0m"
    touch $HOME/.gnupg/gpg-agent.conf
    echo "default-cache-ttl 1" > $HOME/.gnupg/gpg-agent.conf
    echo "max-cache-ttl 1" >> $HOME/.gnupg/gpg-agent.conf
    echo -e "\033[35msending RELOADAGENT to gpg-connect-agent...\033[0m"
    echo RELOADAGENT | gpg-connect-agent

    task="fetching private repo credentials..."
    echo -e "\033[35m\n$task\033[0m"
    mkdir -p $HOME/setup-mac
    curl 'https://raw.githubusercontent.com/cuteweeds/setup-mac/refs/heads/lite/remu.gpg' > $HOME/setup-mac/remu.gpg
    curl 'https://raw.githubusercontent.com/cuteweeds/setup-mac/refs/heads/lite/remu.sh' > $HOME/setup-mac/remu.sh
    cd $HOME/setup-mac
    chmod u+x remu.sh
    bash remu.sh
    
    # Confirm key
    if [[ -f "setup-mac/repo_key" ]]; then
        echo "Key created."
        password=$(cat $HOME/setup-mac/repo_key)
        echo $password
    else
        echo -e "\033[1mError: key mising or corrupt. Try manually regenerating it by running 'setup-mac/remu.sh' or 'gpg -idv remu.gpg > repo_key' and re-running script.\033[0m"
        exit
    fi
fi

cd $HOME
user="cuteweeds"
git clone --bare -b lite https://$user:$password@github.com/cuteweeds/.dotfiles $HOME/.dotfiles

task="writing to .gitignore..."
echo -e "\033[35m\n$task\033[0m"
echo ".dotfiles" >> .gitignore

task="backing up existing config files"
echo -e "\033[35m$task\033[0m"
mkdir -p $HOME/setup-mac/config-backup/.config/gh && mv $HOME/.config/gh/* $HOME/setup-mac/config-backup/.config/gh
mkdir -p $HOME/setup-mac/config-backup/.gnupg && mv $HOME/.gnugp/* $HOME/setup-mac/config-backup/.gnupg
mkdir -p $HOME/setup-mac/config-backup/.liteinstalls && mv $HOME/.liteinstalls/* $HOME/setup-mac/config-backup/.liteinstalls
mkdir -p $HOME/setup-mac/config-backup/.myprefs && mv $HOME/.myprefs/* $HOME/setup-mac/config-backup/.myprefs
mkdir -p $HOME/setup-mac/config-backup/.ssh && mv $HOME/.ssh/* $HOME/setup-mac/config-backup/.ssh
mkdir -p $HOME/setup-mac/config-backup/.userscripts && mv $HOME/.userscripts/* $HOME/setup-mac/config-backup/.userscripts
mv $HOME/.gitconfig $HOME/setup-mac/config-backup/
mv $HOME/.gitignore $HOME/setup-mac/config-backup/
mv $HOME/.runafter $HOME/setup-mac/config-backup/
mv $HOME/.stow-global-ignore $HOME/setup-mac/config-backup/
mv $HOME/.zshrc $HOME/setup-mac/config-backup/
mv $HOME/.Brewfile $HOME/setup-mac/config-backup/
mv $HOME/.README.md $HOME/setup-mac/config-backup/
git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME checkout 2>&1 | grep -v "error:" | grep -v "Please move or remove them before you switch branches" | egrep '.?\s+[^\s]' | sed 's/^.//' |  awk {'print $1'} | xargs -I{} mv {} $HOME/.config-backup/{}

task="checking out .dotfiles"
echo -e "\033[35m$task\033[0m"
git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME checkout lite

task="turning off untracked-file messages"
echo -e "\033[35m$task\033[0m"
git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME config --local status.showUntrackedFiles no 

#echo "writing to .zshrc"
#echo "alias dotfiles=\"/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME\"" >> $HOME/.zshrc
#echo "alias dot=\"/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME\"" >> $HOME/.zshrc

echo "setting aliases"
alias dotfiles="/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME"
alias dot="/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME"

echo -e "checking status\n"
git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME status

echo -e "\n\033[35mIf you see \"On branch <name>\" above, dotfiles installed correctly."
echo -e "\n\033[32m\033[1mUpdating dotfiles"
echo -e  "\n\033[1m\033[36mUse 'dot' instead of 'git' for dotfile maintenance\033[0m\033[36m\n- dot status\n- dot add <file>\n- dot push\n- dotcetera...\033[0m\n"

echo -e "\n\033[1m\033[35mPackages to install\033[0m\n"
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
