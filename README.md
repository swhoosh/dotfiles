```zsh
# Install brew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install git 
brew install git

# Clone this repo
git clone https://github.com/swhoosh/dotfiles.git ~/dotfiles

# Brew Cask
brew bundle --file ~/dotfiles/Brewfile
sudo xattr -dr com.apple.quarantine /Applications/Hidden\ Bar.app

# Run stow on dotfiles directory
cd ~/dotfiles
stow .
```

