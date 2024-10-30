## PROMPT
DIR="$( dirname "${BASH_SOURCE[0]}")"
PS1=
PROMPT_COMMAND=__prompt_command

PERM_INDICATOR="λ"

if [ "$EUID" == "0" ]
then
    PERM_INDICATOR="Ω"
fi

SSH_INDICATOR=""
if [ "$SSH_CLIENT" != "" ]
then
	_SSH_HOST="$(echo $SSH_CLIENT | awk '/./ { print $1 }')"
else
	if [ "$SSH_TTY" != "" ]
	then
		_SSH_HOST="$(hostname)"
	fi
fi
if [ "$_SSH_HOST" != "" ]
then
  SSH_INDICATOR='\[\e[1;36m\]$USER@$_SSH_HOST\[\e[0m\] '
fi

__prompt_command() {
    local exitcode="$?"

    PS1=

    if [ "$exitcode" != "0" ];
    then
        PS1+="\[\e[31m\]----- exit code: $exitcode -----\[\e[39m\]\n"
    fi

    PS1+='$(echo -ne "\033]0;$($DIR/.bash_termtitle)\007")'

    local gitprompt="$($DIR/.bash_gitprompt)"
    PS1+="$SSH_INDICATOR"
    PS1+='\[\e[1;32m\]\w\n'
    PS1+="$gitprompt"
    PS1+='\[\e[1;35m\]$PERM_INDICATOR\[\e[0m\] '
}

## GREETING
if [[ ! "$TERMINAL_EMULATOR" =~ "JediTerm" ]];
then
	fortune "$DIR/greeting/glados" | cowsay -f "$DIR/greeting/glados.cow" -W 80
fi

## ALIASES
alias ll='ls -lAh'
