## PROMPT
DIR="$( dirname "${BASH_SOURCE[0]}")"
if [[ "$DIR" == "." ]]; then
    DIR="$( dirname "$0" )"
fi
PS1=
PROMPT_COMMAND=__prompt_command

PERM_INDICATOR="λ"

if [[ "$EUID" == "0" ]]
then
    PERM_INDICATOR="Ω"
fi

SSH_INDICATOR=""
if [[ "$SSH_CLIENT" != "" ]] || [ "$SSH_TTY" != "" ]
then
	clientIp=$(echo "$SSH_CLIENT" | awk '/./ { print $1 }')
	if [[ "$clientIp" != "127.0.0.1" ]]
	then
		host="$(hostname)"
	  SSH_INDICATOR='\[\e[1;36m\]remote $USER@$host\[\e[0m\] '
	fi
fi

__prompt_command() {
    local exitcode="$?"

    PS1=

    if [[ "$exitcode" != "0" ]];
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

precmd() {
    local exitcode="$?"

    PS1=

    if [[ "$exitcode" != "0" ]];
    then
        PS1+="\033[31m----- exit code: $exitcode -----\033[39m
"
    fi

    local gitprompt="$($DIR/.bash_gitprompt)"

    PS1+="$SSH_INDICATOR"
    CWD="$(pwd)"
    if [[ "$CWD" == "$HOME" ]];
    then
        CWD="~"
    fi
    PS1+="\033[1;32m$CWD
"
    PS1+="$gitprompt"
    PS1+="\033[1;35m$PERM_INDICATOR\033[0m "
    PS1="$(printf $PS1)"
}

## GREETING
if [[ ! "$TERMINAL_EMULATOR" =~ "JediTerm" ]];
then
	fortune "$DIR/greeting/glados" | cowsay -f "$DIR/greeting/glados.cow" -W 80
fi

## ALIASES
alias ll='ls -lAh'
