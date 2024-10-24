/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew update
brew upgrade
brew install --cask git-credential-manager
git clone https://github.com/cuteweeds/.dotfiles ~/.dotfiles
cd .dotfiles
./install-dotfiles.sh
