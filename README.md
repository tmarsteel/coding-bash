# coding-bash
Various extensions to a bash shell to aid with Git &amp; Coding Projects

## How to install

Append the contents of the `.bashrc` file in this repository to your own `~/.bashrc`.

Copy the other files to `~` (except `LICENSE`). You should be ready to go.

## Features

### Terminal Title

* Displays name current directory
* when you are within the directory tree of a git repository or a directory that is managed by a build tool, indicates that:
** the git root is indicated using `Σ` (adjustable, see below), e.g. `Σ some-repository`
** the build tool root is indicated using `γ` (adjustable, see below), e.g. `γ some-maven-project`
** when git root and build tool root differ, both are displayed separately, e.g. `Σ my-app-server γ submodule1`
** when they are equal, the two indicators are combined: `Σγ my-app-server`

The git root is determined using `git rev-parse --show-toplevel`, see https://git-scm.com/docs/git-rev-parse.

Build tools are recognized using a file sepcific to them (e.g. Gradle: `build.gradle`, Composer: `composer.json`,
Maven: `pom.xml`, Cargo: `Cargo.toml`). You can adjust/extend this, see below.

### Prompt

The prompt **spans two lines** and has this format:

```
<current directory in green>
[<repository information in blue><space>]<prompt char in pruple><space><caret>
```

By default, the prompt char for non-root-users is `λ` and `Ω` for root (can be changed, see below).

E.g.:

```
~
λ cd /tmp
/tmp
λ cd /var/www
/var/www
λ sudo bash
[sudo] password for john.doe: 
/var/www
Ω echo "im root!"
im root!
/var/www
Ω 
```

#### Repository information

When within a directory that is managed by git, displays the repository name and the current branch, e.g.:

```
~/coding/rust
Σ rust > master λ git remote get-url origin
https://github.com/rust-lang/rust.git
~/coding/rust
Σ rust > master λ git checkout try
Switched to branch 'try'
Your branch is up-to-date with 'origin/try'.
~/coding/rust
Σ rust > try λ echo "hi!"
hi!
~/coding/rust
Σ rust > try λ 
```

The repository name is inferred from the URL of the remote `origin`.

#### Exit code

If the exit-code of the previous command is not null, displays `---- exit code $? -----` before the prompt, e.g.

```
~
λ basename
basename: missing operand
Try 'basename --help' for more information.
----- exit code: 1 -----
~
λ 
```

### Git-Subcommands

Helpful subcommands are included in the `git-*.sh` files. Add them to your git installation using aliases, e.g.:

    $ git config --global alias.ready "!/path/to/the/checkout/git-ready.sh"
    $ git ready
    .... stuff happens ....
    
#### git-ready

Starts a new branch from an updated master. Stashes changes in the working copy if any.   
Runs maintenance commands alongside (`remote prune`, `prune`, `gc`).

*Example:*

    ~/project (feature/new-button) 
    $ git ready bugfix
    ...
    ~/project (bugfix)
    $

## Adjusting

Here is where you can change things:

* Indicators in terminal title: `.bash_termtitle`; there are two lines:
  `repositoryIndicator="Σ"`
  `codingProjectIndicator="γ"`
* repository information indicator: `.bash_gitprompt` on the last line
* prompt chars: `.bashrc`, find these two lines:
  `PERM_INDICATOR="λ"`
  `PERM_INDICATOR="Ω"`
* coding project detection: to add support for a new build tool, add the file specific to that tool (e.g. `package.json` for NPM)
  to this line in `.bash_termtitle`: `codingProjectDetectionFiles=(pom.xml Cargo.toml build.gradle composer.json)`
