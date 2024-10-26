echo -e "\033[34m\033[1mcw setup script \nfrom https://raw.githubusercontent.com/cuteweeds/setup-mac/HEAD/setup.sh\033[0m"
## Check for git, exit if it's missing
#if test ! $(which git); then
#  echo -e "\nGit not found. Install it whatever way is best and re-run this script."
#  exit
#fi
#
## Check for xcode-select,
## Install if we don't have it
#if test ! $(which xcode-select); then
#  echo -e "\nInstalling xcode-stuff"
#  xcode-select --install
#fi
#
## Install homebrew if we don't have it
#if test ! $(which brew); then
#  echo -e "\nInstalling homebrew..."
#  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
#fi
#
#brew update
#brew upgrade
#
#brew install --cask git-credential-manager
#brew install gh
## Needed to log into github for private repo access
#
#brew cleanup
#
#
#echo -e "\nLog into git"
#gh auth login

task="setting up dotfiles..."
echo -e "\033[36m\n$task"
cd $HOME
git clone --bare https://github.com/cuteweeds/.dotfiles $HOME/.dotfiles && lastask=$task

task="writing to .gitignore..."
echo -e "\033[36m\n$task"
echo ".dotfiles" >> .gitignore && lasttask=$task

task="backing up existing config files"
echo "$task"
mkdir -p $HOME/.config-backup && git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME checkout 2>&1 | egrep "\s+.+:\s+." | grep -v "^error:" | grep -v "^Please move or remove them before you switch branches" | awk {'print $1'} | xargs -I{} mv {} $HOME/.config-backup/{} && lasttask=$task

#task="checking out .dotfiles"
#echo -e "\033[36m$task
#git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME checkout

task="turning off untracked-file messages"
echo "$task"
git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME config --local status.showUntrackedFiles no && lasttask=$task

thisblock="8"
echo "Press enter to continue..."
read -s wait

exit

echo -e "checking status\n"
git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME status

#echo "writing to .zshrc"
#echo "alias dotfiles=\"/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME\"" >> $HOME/.zshrc
#echo "alias dot=\"/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME\"" >> $HOME/.zshrc

echo "setting aliases"
alias dotfiles="/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME"
alias dot="/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME"

echo "Press enter to continue..."
read -s wait

echo -e "\nIf you see \"On branch <name>\" above, dotfiles installed correctly."
echo -e "\n\033[32m\033[1mUpdating dotfiles"
echo -e  "\n\033[1m\033[36mUse 'dot' instead of 'git' for dotfile maintenance\033[0m\033[36m\n- dot status\n- dot add <file>\n- dot push\n- dotcetera...\033[0m\n"

echo "Press enter to continue..."
read -s wait

echo -e "\n\033[1m\033[36mPackage Install list\033[0m\n"
cat Brewfile

echo "Press enter to continue..."
read -s

brew bundle install
brew cleanup
