# HELPER ALIASES
alias grep='grep --color=auto'  # Always highlight grep search term.
alias ping='ping -c 5'          # Pings with 5 packets, not unlimited.
alias df='df -h'                # Disk free, in gigabytes, not bytes.
alias du='du -h -c'             # Calculate total disk usage for a folder.
alias sgi='sudo gem install'    # Install Ruby gems.
alias be='bundle exec'          # Shortcut for Ruby environment activation.
alias clr='clear;echo "Currently logged in on $(tty), as $(whoami) in directory $(pwd)."'
alias svim="sudo vim"           # Run vim as super user.
alias virtualenv3="virtualenv -p python3"
alias cpdir="cp -R"