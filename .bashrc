## PROMP
DIR="$( dirname "${BASH_SOURCE[0]}")"
PS1=
PROMPT_COMMAND=__prompt_command

PERM_INDICATOR="λ"

if [ "$EUID" == "0" ]
then
    PERM_INDICATOR="Ω"
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
    PS1+='\[\e[1;32m\]\w\n'
    PS1+="$gitprompt"
    PS1+='\[\e[1;35m\]$PERM_INDICATOR\[\e[0m\] '
}
