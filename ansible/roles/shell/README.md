# myshell

* Shell customizations
* Scripts that live in ~/bin
* SSH public key halves, config, authorized_keys file

## fish/py3

```fish
# Define alias in shell
alias cat "/usr/games/lolcat"

# Define alias in config file
alias cat="/usr/games/lolcat"

# This is equivalent to entering the following function:
function cat
    rm -i $argv
end

# Then, to save it across terminal sessions:
funcsave cat
```

## zsh/py2

```sh
sudo apt-get install zsh fortune cowsay python-pip mlocate git
sudo pip install lolcat
```

vi /etc/profile, addend to the end:

```sh
alias cat='/usr/local/bin/lolcat'
/usr/games/fortune | /usr/games/cowsay -f tux | /usr/local/bin/lolcat
alias seppuku='ps -u `whoami` -o pid|grep -vi pid|xargs kill -9'
```
