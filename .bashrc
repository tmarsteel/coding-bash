## PROMP
PS1=
PROMPT_COMMAND=__prompt_command

__prompt_command() {
    local exitcode="$?"

    PS1=

    if [ "$exitcode" != "0" ];
    then
        PS1+="\e[31m----- exit code: $exitcode -----\e[39m\n"
    fi
    
    if [ "$EUID" -ne 0 ]
    then
	    PERM_INDICATOR="λ"
    else
	    PERM_INDICATOR="Ω"
    fi

    PS1+='$(echo -ne "\033]0;$(~/.bash_termtitle)\007")\[\033[1;32m\]\w\n\[\033[1;34m\]$(~/.bash_gitprompt)\[\033[1;35m\]$PERM_INDICATOR\[\033[0m\] '
}
