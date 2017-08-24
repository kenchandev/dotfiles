#!/bin/sh
#
# Node Version Manager (nvm)
#
# This executes the installation script for nvm.

# Check for Node Version Manager
if test ! $(which nvm)
then
  echo "  Installing nvm..."

  ruby -e "$(curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.2/install.sh | bash)"
fi

exit 0