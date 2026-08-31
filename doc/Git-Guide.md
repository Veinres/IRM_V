# Git Guide

## Introduction

This is a short introduction to Git. Git has a wealth of features, but only a limited set is sufficient to start 
collaborating.
As such, this guide is not ment to be anywhere close to complete, but rather to allow a new user to get going as quickly as possible.

For the interested, there are a lot of very good guides and tutorials on the internet. Some are listed in the [Further Reading](#Further-Reading-and-more-about-Git) section.

## Table of Contents

[[_TOC_]]

## What is Git?

Git is primarily a "source control managment" or, more precicely, a "distributed version control" software.
Without going into technical details (i.e. the following is a bit of a simplification), Git allows taking snapshots of the current state of a directory, usually containing source code, and keeps track of the changes that have been made.
This allows, for example, to go back to previous points in the history of the project in case something goes wrong.

The history of a project is stored as a chain of so called **commits**, which themselves can be viewed as a set of changes. I.e. the state of the project at any time is the sum of all commits (or sets of changes) in its history.

However, in reality, the history of a project is oftentimes not linear and Git also accomodates for this fact. When working on something new, not having to modify a version of the source code other people might rely on can be desireable.
In Git, this is achieved with the concept of **branches**. 
With branches it is possible to, at any point in the history of a project, start working on new, parallel version of the code.
Every Git project has a default branch, oftentimes called **main**, that hosts the main (or stable) version of the project.
Commonly, there is a second branch called **development** or simply **dev**. This is a sort of a shared working copy on which the actual development takes places.
In addition to these two branches found in most Git projects, there can be any number of additional branches, for example for fixing a bug or working on a new feature.
Once work on a particular branch is finished, it is usually **merged** back into its parent branch, applying all changes that were made in the child branch to the parent.

All this information on commits, branches etc. is stored locally on the user's computer in a hidden folder called '.git'. This is what's called a git repository. But besides providing source control, Git is also intended for collaborative work. For this purpose, there is usually also a 'remote' copy of the repository stored on a server somewhere, which allows to synchronize and distribute everybody's contributions. Often there are graphical web interfaces for these remote repositories that allow viewing the code online and have some other extra features.

## Why use Git?

When done right, using git brings many advantages.
Just to name a few:

- Histroy is preserved
	- Can go back if something breaks or if and old simulation needs to be run again
- Collaboration is easy
	- Contributers can work in parallel
	- Work from different people can be integrated easily
	- Code can be sheared easily
- Git is FOSS (**F**ree and **O**pen **S**ource **S**oftware) ;)
- ...

## Getting Git

Git is primarily a command line program, which can be a bit intimidating. However, there are also graphical user interface (GUI) clients which can make using Git more comfortable for users not used to working directly in a terminal. A base install of the command line interface (CLI) application is however still required. 

### Linux

All but the most basic Linux distributions come with Git pre-installed. If this is not the case, it can be found in most popular package managers. Instructions on how to install Git on a number of different distributions can be found [here](https://git-scm.com/download/linux).

### Windows

Git for Windows can be downloaded [here](https://git-scm.com/download/win). Besides the standalone installer, there is also the possibility to download a portable version of Git ("thumbdrive edition"), which doesn't require installation and thus also no administrator rights.

### macOS

Instructions on how to install Git on macOS can be found [here](https://git-scm.com/download/mac).

### GUI Clients

GUI clients are not required to work with Git, but it can be more comfortable for some users. When using the standalone installer for Windows, Git also ships directly with a baisc GUI client. A list of other available GUI clients can be found [here](https://git-scm.com/download/gui).

## Starting with Git

### Getting around in Bash

As mentioned before, Git is primarily a command line program. It was originally developed on GNU/Linux, for Linux machines and in particular for the Linux kernel development itself. As such, when running on Windows it will open a bash (Bourne-again shell) unix shell (There's now also an option to use the Windows CMD instead).
So using Git from the command line requires at least a minimal knowledge of shell commands. The most important once are listed below:

**Note:** Arguments in brackets (`[]`) are optional and arguments between less-than and greater-than signs (`<>`) are required.

|name | usage | description |
|-|-|-|
| pwd (**p**rint **w**orking **d**irectory) | `pwd` | print the current working directory |
| ls (**l**i**s**t) | `ls [OPTIONS] [PATH]` | list files and folders in the current directory |
| cd (**c**hange **d**irectory) | `cd [OPTIONS] <PATH>` | change to a different working directory (specified either as relative or absolute path) |
| | `cd <SUBFOLDER>` | move to a subfolder |
| | `cd ..` | move to the parent folder |
| mkdir | `mkdir <FOLDERNAME>` | create a subfolder |
| cp | `cp [OPTIONS] <SOURCE> <TARGET>` | copy a file or folder |
| mv | `mv [OPTIONS] <SOURCE> <TARGET>` | move (or rename) a file or folder |
| rm | `rm [OPTIONS] <FILE/FOLDER>` | permanently delete a file or folder |
| | `rm -r <FOLDER>` | recursively delete a folder and its contents |
| cat | `cat [OPTIONS] <FILE>` | display the contents of a file |
| touch | `touch <FILENAME>` | create an empty file |
| nano | `nano [FILE]` | open a file in nano (a simplistic texteditor) |
| exit | `exit`| close the terminal window |

Most of these commands accept the `-h` or `--help` option.
There are of course a lot of other usefull commands worth mentionioning, but the goal here is to keep it brief.
Similar to Git, there are again many great online resources for those who are interested.

There are a couple other useful points worth mentioning:
- Unix based systems (macOS, Linux, etc.) use forward-slashes `/` in file paths unlike Windows which uses back-slashes `\`.[^1]
- Like in the Matlab Command Window, previously used commands can be accessed by using the *arrow-up* key. Alternatively, the command `history` displays the last 500 commands. To repeat a command, just type an exclamation mark `!` followed by the number of the command as indicated by the history command.
- Terminal emulators usually have auto-completion. When starting to write a command or filepath, pressing the *tab* key will list possible completions, or, if only one is possible, automatically complete what was being written.
- When specifying file/folder paths, some wildcards can be used. The most common are `*` and `?`.
	- `*` stands for any subsitution. E.g., if the files *analyse_fct_ArC.m*, and *analyse_fct_ArCu.m* are present in the current folder, `rm analyse_fct_*.m` will remove them both. Depending on the command (especially with `rm`), this should be used with some caution!
	- `?` stands for any single character substitution. E.g., if the files *img1.png*, *img2.png* and *img10.png* are present in the current folder, `rm img?.png` will remove *img1.png* and *img2.png*, but not *img10.png*.
- Arguments (p.ex. filenames/paths) that contain spaces need to be specified between either double quotes (`"example file.png"`) or single quotes (`'example file.png'`). It is therefore recommended to avoid using spaces in file or folder names.

[^1]: Please use Matlab's `fullfile` function when specifying filepaths in the IRM source code to avoid issues when using the code on a different type of operating system. It will automatically select forward- or backward-slashes depending on the system on which it is run.

### Important Git Commands

Below is a (non-exhaustive) list of important Git commands. All Git commands begin with the word `git`.

#### Creating a repository

These are commands that are usually only used when starting to work on a repository.

| name | usage | description |
|-|-|-|
| init | `git init` | create an empty repository in the current folder |
| clone | `git clone <URL>` | clone (get a copy of) a remote repository |
| config | `git config ...` | view/change the configuration of git |

#### Basic Commands

These are commands that are typically used on a daily basis.

| name | usage | description |
|-|-|-|
| help | `git help` | display a list of all git commands |
| |`git help [COMMAND]`| display more detailed information about a command |
| status | `git status` | display the current state of your repository |
| add | `git add <FILE1> [FILE2] [FILE3] ...` | stage changes (add files/changes to the next commit) |
| diff | `git diff <FILE>` | show the changes that were made to a file since the last commit |
| restore | `git restore <FILE1> [FILE2] [FILE3] ...` | revert the changes made to files since the last commit |
| | `git restore --staged <FILE1> [FILE2] [FILE3] ...` | unstage changes (remove files/changes from the next commit \- i.e. undo the `git add` command) |
| commit | `git commit` | commit staged changes (this will open a texteditor to allow adding a message) |
| | `git commit -m <COMMIT-MESSAGE>` | commit staged changes with a commit message (without opening a texteditor) |
| | `git commit -m <COMMIT-MESSAGE> -m <DETAILED-MESSAGE>` | commit staged chances with a commit message and a more detailed explanation |
| pull | `git pull` | download the latest changes from the remote repository |
| push | `git push` | upload your changes to the remote repository |

#### Slightly Advanced Commands

These are commands that come in handy in particular circumstances or when adopting an advanced workflow.

| name | usage | description |
|-|-|-|
| branch | `git branch <BRANCH-NAME>` | create a new branch |
| checkout | `git checkout <BRANCH>` | move to a different branch |
| merge | `git merge <BRANCH>` | incorporate the changes from a different branch into the current one |
| stash | `git stash` | save the current changes without commiting them |
| | `git stash apply` | reapply the stashed changes |
| tag | `git tag <TAG-NAME>` | create a named alias for the current commit |

### First Steps

To be able to interact with the remote repository on GitLab, a few things need to be done first.
1. An SSH key needs to be set-up to allow for secure communication with GitLab.
2. Your Git needs to be configured with your email-address, so that GitLab knows who you are and allows you to pull from or push to the remote repository.
3. Clone this repository to get your own working copy of it.

#### Add an SSH key to your GitLab profile

1. If you don't already have an SSH key, generate one. ( If you already have an SSH key, proceed with step 7. )
2. This can be done by opening a terminal (on Windows git-bash) and using the command `ssh-keygen -t ed25519 [-c <comment>]`.
3. You will be promted to select a location for the key-file. Just press *Enter* to continue with the default location.
4. Next, you will be promted to specify a passphrase. Choose a secure password, however keep in mind that you will have to type it whenever you interact with the remote repository. It will not be possible to change the password later. However should you forget the password, you can simply generate and upload a new key.
5. Go to the folder in which your key was generated. By default this is *~/.ssh*, i.e. type `cd ~/.ssh` in either your OS native terminal or, if you're in windows, in your git-bash terminal.
6. Copy the contents of the *id_ed25519.pub* file. In bash this can be done using the command `cat id_ed25519.pub`, marking the output with your mouse and then right-clicking it and choosing "copy" in the context menu.
7. Go to the [SSH keys](https://gitlab.liu.se/-/profile/keys) section in the preferences page of your GitLab profile.
8. Paste the key into the *Key* field and press *Add key*.

#### Configure Git

Use the following two commands in your terminal to set your name and email-address:

```
git config --global user.email "john.doe@domain.org"
git config --global user.name "John Doe"
```

Replace `john.doe@domain.org` with the email address your GitLab account uses and `John Doe` with the name with which you want to sign your commits.

#### Clone the repository

1. In your terminal, move to the directory in which you want to create a copy of this repository.
2. Execute the following command:
```
git clone git@gitlab.liu.se:irm-group/irm.git
```
3. Enter the passphrase for your SSH key.
4. At this point, Git will create a new folder called *irm* in the current working directory and start downloading the files.
5. Once Git is done, type `cd irm` followed by `git status` to verify that everything is in order. The output should be:
```
On branch main
Your branch is up to date with 'origin/main'.
```

#### Switch to a different branch

If you want to use a version of this repository which is located on a different branch, this can be done by executing the following command:
```
git checkout <branch/tag>
```
where `<branch/tag>` should be replaced with the name of the target branch (e.g. `git checkout dev` to switch to the *dev* branch).

## Git Workflow

### Basics

The basic Git Workflow is pretty simple:

1. **Make changes:** Work as you would normally do.
2. **Stage changes:** Once you have finished working on something, stage all the changes you think should go into your next commit. To see what changes you have made, use `git status` to list the "touched" files and `git diff <FILE>` to see what you changes made to a specific file. Once you have verfied your changes to a particular file, use `git add <FILE>` to add it to the index (this is, simply put, the list of changes to be committed).
3. **Commit changes:** Use `git status` again. Verify, that everything you want to commit is staged and, more importantly, nothing is staged you don't want to commit. Once you're sure everything is in order, use `git commit` to commit the changes. Give your commit a descriptive but short message that describes what you have done.
4. Rince and repeat ;)

These first four steps should cover the basics of the "local" workflow. However, when working with other people, it becomes necessary to synchronize the work each contributor does using the remote repository.

5. **Pull changes:** If you need to get the latest changes some other contributor made, this is done by using the command `git pull`. This is also the first step, if you want or need to share the work you did yourself (Git will not allow a push if the remote repository is "ahead" of the local repository).
6. **Manually merge (if necessary):** Usually, the new commits from the remote repository will get integrated into the local repository automatically. However, if you changed something in your own commits that someone else has also changed, a conflict can arise where Git doesn't know which changes should be kept. In that case you will have to resolve the conflict manually and perform a so-called "merge commit". 
7. **Push changes:** Once you have performed a pull, if necessary resolved all merge conflicts, and still have own commits that aren't yet on the remote repository, your local repository will be ahead of the remote. You can now upload your own changes by using the command `git push`.

*Some additional notes:*
- **The staging area:** When using `git status`, you will typically see three sections: 1) *Changes to be commited* (the index) 2) *Modifie files* not staged for the commit and 3) *Untracked files* git doesn't care about. The *status* command will also suggest possible actions you can perform with files in each of these three sections.
- **The commit message:** Generally, the commit message should be around 50 characters long and it's commonly written in the imperative tense (E.g. "Fix bug xy" instead of "Fixed bug xy" or "Fixes bug xy"). If necessary, a second longer description separated by a blank line can be added. For a project of this size, this isn't all that important. However, keeping the first part of the commit message short is nevertheless encouraged.
- **Uncommited changes:** To be able to pull changes, the local repository has to be in a clean state, i.e. there cannot be any uncommited changes (untracked files are fine), so it might be necessary to submit a commit before pulling. A good habit can be to perform a pull whenever one happens to have a clean repository. This assures that the remote repository will not get to much ahead, which would make integrating your own changes more difficult.
- **Merge conflicts:** Git is smart and can integrate changes even if two commits modified the same file. However, if these changes affect the same lines of code, choosing which change should be kept is left to the user. In this case, Git will notify the user that there are unmerged conflicts. The affected files will be listed under *both modified* when using the *status* command. For each conflicting change, Git inserts the changes from both commits between some metadata (from which commit both changes originate). To easily find those conflicts, just search for `<<<<<<<` (seven less-than signs). In Matlab, for example, this can be done using *Ctrl+F*.

### Branches and Merge Requests

In this repository, the *main* and *dev* branches are protected. This means, that they will refuse any attempts to directly modify them (in particular, pushing changes to them). To apply changes to them, a **merge request** needs to be opened on [GitLab](https://gitlab.liu.se/irm-group/irm/-/merge_requests). A *merge request* is, as the name states, a request to merge changes from one branch into another. When opened, the changes have to be accepted by two or more contributors before they are actually applied.

The intended workflow is as follows:

1. Create an new branch for something you need to work on.
2. Work on this new branch. You can also periodically merge new commits from the parent branch if necessary.
3. Once the work is done, merge the child branch back into its parent. If the parent is *dev*, this has to be done via a *merge request*. *Merge request* into the *main* branch are only granted from the *dev* branch. If the parent branch is neither *main* nor *dev*, the branches can be merged without a *merge request*.

*Some additional notes:*
- **Naming Convention:** Besides *main* and *dev*, branches (and tags) should use a "path-like" naming convention: `<topic>/<subtopic>(/...)`
Where the topic can be the type of work that is being performed or something else. Examples on the repo are 'refactor/pre-cal', 'C-IRM/main' or 'Cu-IRM/HistPaper/FirstRevision'.
This is mostly only important when there might be a point where it would be useful to have multiple tags/branches regarding the same topic. Use something like 'C-IRM/main' instead of just 'C-IRM', for example.
*(The reason for this rule is, that Git uses a directory structure to represent branches and tags under the hood. This means, that if, for example, a branch or tag named 'C-IRM' exists, it won't be possible to create a branch/tag named 'C-IRM/xy' at a later point in time, because 'C-IRM' is already a file, which, unlike a folder, cannot contain any files or folders itself.)*\
For branches, "type of work" groups/topics are preffered. Examples are: **wip** (short for "work in progress" - a bit of a catch all), **refactor** (for refactoring work), **exp** (short for "experimental" for experimenting), **legacy** (for old version), **test** (short for "testing" - to test that everything is working as it should), **impl** or **feat** (short for "implementation" respectively "feature" - for adding new materials or features).\
Tags are usually used to mark a version that is important for some reason. This could, for example, be because it was used for a publicaiton or at an otherwise important stage. The chosen name should reflect this.

## Further Reading and more about Git

Below are some additional resources on selected topics, ordered by depth/complexity:

### Git

Some excellent guides, tutorials and references can be found directly on the [official Git Documentation page](https://git-scm.com/docs):

- [Some introduction videos which probably explain Git better than this Guide ever could](https://git-scm.com/videos)
- [A visual (and interactive) cheetsheet](https://ndpsoftware.com/git-cheatsheet.html#loc=index;)
- [A completely free book on Git](https://git-scm.com/book/en/v2)

### GitLab

- [GitLab User Documentation](https://docs.gitlab.com/ee/user/index.html)

### Bash

Some more information on Unix and Bash in particular:

- [Command Line for Beginners](https://ubuntu.com/tutorials/command-line-for-beginners#1-overview) (This assumes you're using Ubuntu, but most things will apply to any unix shell, including the Git-Bash terminal)
- [Learn Unix](https://www.tutorialspoint.com/unix/index.htm)
- [The Bash-Hacker Wiki](https://wiki.bash-hackers.org/) (more about Bash as a scripting language)

### Markdown

Markdown is a very simple text mark up language that can be used pretty much everywhere on GitLab (Commit messages, merge requests, comments, etc. . This document, for example, is also written in Markdown):

- [GitHub Flavoured Markdown](https://docs.gitlab.com/ee/user/markdown.html) (Documentation for the GitLab specific Markdown features)

---
