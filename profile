# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022

# if running bash
if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
	. "$HOME/.bashrc"
    fi
fi

PATH="$HOME/.rbenv/bin:$PATH"

if [ -f "$HOME/Config/git/git_prompt.sh" ]; then
  source $HOME/Config/git/git_prompt.sh
  GIT_PS1_SHOWDIRTYSTATE=1
  GIT_PS1_SHOWUNTRACKED_FILES=1

  export PROMPT_COMMAND='__git_ps1 "\u@\h:\w" "\\\$ "'
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

source $HOME/Hubbub/chef/env
eval "$(rbenv init -)"

export EDITOR="vim"
export MAKE_ARGS="-j$(grep processor /proc/cpuinfo | wc -l)"

eval $(keychain --eval --agents ssh -Q --quiet id_rsa)

alias gs="git status"
alias gcm="git commit -m"
alias gaa="git add --all"

alias db="./script/dbconsole"
