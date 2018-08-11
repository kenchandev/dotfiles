# Load nvm.
# https://github.com/creationix/nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"

# Load gvm.
# https://github.com/moovweb/gvm
export GVM_DIR="$HOME/.gvm"
[[ -s "$GVM_DIR/scripts/gvm" ]] && source "$GVM_DIR/scripts/gvm"

# Load the default .profile.
[[ -s "$HOME/.profile" ]] && source "$HOME/.profile"

# Set Vim as default editor.
export EDITOR="vim"
