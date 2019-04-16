# Git-Subcommands

Helpful subcommands are included in the `git-*.sh` files. Add them to your git installation using aliases, e.g.:

    $ git config --global alias.ready "!/path/to/the/checkout/git-ready.sh"
    $ git ready
    .... stuff happens ....
    
### git-ready

Starts a new branch from an updated master. Stashes changes in the working copy if any.   
Runs maintenance commands alongside (`remote prune`, `prune`, `gc`).

*Example:*

    ~/project (feature/new-button) 
    $ git ready bugfix
    ...
    ~/project (bugfix)
    $

### git-fuckit

Adds all changes in the current directory, amends to the last commit and force-pushes with `--force-with-lease` (prevents data-loss on a race).

### git-qc

Adds all changes in the git project (not just the current directory) and commits.

If the currently checked out branch follows the pattern \w{2,}-\d+ (usually the pattern of JIRA issue refs), prepends that name to the commit message with a colon, e.g.:

    $ git status
    On branch PRJ-123
    $ git qc some message
    
Creates a new commit with message "PRJ-123: some message"

### git-default-branch

Prints the default branch and exits with status 0. If not in a git repository or no defualt branch is recognized, prints an error message and exits with status 1.

### git-update

Updates the current branch from the default branch und pushes the changes. The method can be chosen (`--merge` or `--rebase`), the default is rebase.

Unless there are conflicts after merging or rebasing, the changes are pushed to the tracking branch.

If done with rebase, the push to the remote is done with the `--force-with-lease` flag to make sure the remote branch did not change.

### git-squash

Finds the commits between the remote default branch and HEAD. Combines them into one commit with the message as the eldest and gives
you a chance to edit that message (`--edit` flag to `git commit`). Then pushes using `--force-with-lease` unless the `--no-push` flag
is given.
