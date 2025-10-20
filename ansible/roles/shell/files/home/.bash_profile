# Ensure user-installed binaries take precedence
export PATH=~/bin:/usr/local/bin:$PATH

if [ -f $(brew --prefix)/etc/bash_completion ]; then
    source $(brew --prefix)/etc/bash_completion
fi

# Load .bashrc if it exists
test -f ~/.bashrc && source ~/.bashrc

if which rbenv > /dev/null; then
  export RBENV_ROOT=/usr/local/var/rbenv
  eval "$(rbenv init -)"
fi
