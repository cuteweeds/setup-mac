# Check for git, exit if it's missing
if test ! $(which git); then
  echo "Git not found. Install it whatever way is best and re-run this script."
  exit
fi

# Check for xcode-select,
# Install if we don't have it
if test ! $(which xcode-select); then
  echo "Installing xcode-stuff"
  xcode-select --install
fi

# Install homebrew if we don't have it
if test ! $(which brew); then
  echo "Installing homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
brew update
brew upgrade

brew install --cask git-credential-manager
# Needed to log into github for private repo access

echo -e "\nSetting up dotfiles.."
cd ~/

echo "alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'" >> $HOME/.zshrc
echo "alias dot='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'" >> $HOME/.zshrc
echo ".dotfiles" >> .gitignore

git clone --bare https://github.com/cuteweeds/.dotfiles $HOME/.dotfiles
alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'

echo -e "\n...backing up existing config files"
mkdir -p $HOME/.config-backup && \
dotfiles checkout 2>&1 | egrep "\s+\." | awk {'print $1'} | \
xargs -I{} mv {} $HOME/.config-backup/{}
#not sure this is needed 
#dotfiles checkout

dotfiles config --local status.showUntrackedFiles no

dot status
echo -e "\nIf you see \"On branch <name>\" above, dotfiles installed correctly."
echo -e "\n\033[1m\033[32mImportant commands"
echo -e "\033[0m\033[32mstatus\t.dotfiles repo status"
echo -e "dot add\tadd file (from ~/)"
echo -e "dot commit, dot push etc.\033[0m"


#git clone https://github.com/cuteweeds/.dotfiles ~/.dotfiles
#cd .dotfiles
#./install-dotfiles.sh