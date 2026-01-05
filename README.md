```zsh
# Install brew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install git 
brew install git

# Clone this repo
git clone https://github.com/swoosh/dotfiles.git ~/dotfiles

# Install stow
brew install stow

# Run stow on dotfiles directory
cd ~/dotfiles
stow .

```

