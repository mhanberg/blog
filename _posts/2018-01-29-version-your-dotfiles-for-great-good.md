---
layout: Blog.PostLayout
title: Version Your Dotfiles for Great Good
date: 2018-01-29 09:00:00 EST
categories: post
desc: Guide on how to set up a versioned (using git) set of dotfiles.
permalink: post/2018/01/29/version-your-dotfiles-for-great-good/
---

### What are dotfiles?

Your dotfiles are the hidden files or folders that live in your home directory, for example your `.vimrc` and your `.bashrc`.

### What do I mean by version?

By "version", I mean to track your dotfiles using a version control system, like git, and a hosting service, like Github.

### Why would you want to version them?

Versioning your dotfiles allows you to track them and to be able to share them between computers, making it easy to provision a new computer.

### Let's get started

There's a good chance that you arleady have some dotfiles, don't worry, it's easy to start tracking them. Our first order of business is to install a handy suite of tools called [rcm](https://github.com/thoughtbot/rcm), which abstracts the process of symlinking our dotfiles.

On macOS we would install via [Homebrew](https://brew.sh/).

```shell
$ brew install rcm
```

rcm expects a `~/.dotfiles` directory, so let's create that and initialize our git repository.

```shell
$ mkdir ~/.dotfiles && cd ~/.dotfiles && git init
```

At this point, if you have any dotfiles (you probably do), you'll want to add them to your `~/.dotfiles` directory, and for this, we use the [mkrc](http://thoughtbot.github.io/rcm/mkrc.1.html) tool provided by rcm.

```shell
$ mkrc .vimrc
$ mkrc .zshrc
$ mkrc .rubocop.yml
```

At this point, rcm has copied these files to your `~/.dotfiles` directory with the dot stripped from the name (`.vimrc -> vimrc`) and replaced the copy in your home directory with a [symlink](https://en.wikipedia.org/wiki/Symbolic_link) to the new file in your `~/.dotfiles` directory.

#### What about my vim plugins?

For most vim plugin managers, you are probably going to be cloning at least one git repository somewhere in your `~/.vim` directory. If you don't plan on ever updating these repos, you can go ahead and run `mkrc .vim`. 

If you want to be able to update these plugins (or any other tool you use which relies on a git repo), you'll need to use [git submodules](http://www.vogella.com/tutorials/GitSubmodules/article.html). I attempted to turn my existing vim plugins into submodules within my `.dotfiles` repository, but I wasn't successful. So instead of re-cloning each plugin as a submodule, I decided to switch to a vim plugin manager that doesn't require manually cloning repos.

I opted to start using [vim-plug](https://github.com/junegunn/vim-plug) over [pathogen](https://github.com/tpope/vim-pathogen), which requires less boilerplate and all of the configuration goes in your `.vimrc`. 

Once I was done, the section of my `.vimrc` handling my vim plugins looked like so:

```viml
" Install vim-plug and plugins if vim-plug is not already installed
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

" Plugins
call plug#begin('~/.vim/bundle')
Plug 'slashmili/alchemist.vim'
Plug 'kien/ctrlp.vim'
Plug 'vim-airline/vim-airline'
Plug 'tpope/vim-bundler'
Plug 'tpope/vim-dispatch'
Plug 'elixir-editors/vim-elixir'
Plug 'tpope/vim-endwise'
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'
Plug 'JamshedVesuna/vim-markdown-preview'
Plug 'tpope/vim-rails'
Plug 'tpope/vim-sensible'
Plug 'janko-m/vim-test'
Plug 'christoomey/vim-tmux-navigator'
call plug#end()
```

#### Yeah, but what about the submodules I can't avoid making?

Thought you might ask that, I encountered the same challenge. I use [oh-my-zsh](https://github.com/robbyrussell/oh-my-zsh) for [zsh](https://en.wikipedia.org/wiki/Z_shell) customizations (mostly the themes¯\\\_(ツ)\_/¯ ), which relies on a git repository in your home directory `.oh-my-zsh`.

While I wasn't able to transfer the existing directory to my new `.dotfiles` directory, I was able to reclone it as a git submodule.

```shell
$ cd ~/.dotfiles
$ git submodule add -b master <repo url>
$ git submodule init # you should only have to run this the first time
$ rcup -v
```

The submodule is set up to track the master branch, has been cloned into your repository, and a symlink to your home directory has been made using the [rcup](http://thoughtbot.github.io/rcm/rcup.1.html) tool provided by rcm.

If you wish to update it at any time, you only need to move into the directory of the submodule and do a `git pull`, followed by  returning to the parent repository and committing the change.

### Final Steps

Now that you have all of your dotfiles in a git repository, it's time to push that repository to Github and figure out how you are going to install these dotfiles the next time you are setting up a computer.

#### Provisioning a new machine with your dotfiles

This is the part we've been working towards, and thanks to our efforts, this part is a breeze.

```shell
# Install git if not installed
# Install rcm

$ git clone --recursive <url> ~/.dotfiles
$ rcup -v
```

Voila! 

If you want to make it even easier to install, rcm provides a utlity to generate a standalone install script.

> The rcup(1) tool can be used to generate a portable shell script. Instead of running a command such as ln(1) or rm(1), it will print the command to stdout. This is controlled with the -g flag. Note that this will generate a script to create an exact replica of the synchronization, including tags, host-specific files, and dotfiles directories.
>
> `env RCRC=/dev/null rcup -B 0 -g > install.sh`
>
> Using the above command, you can now run install.sh to install (or re-install) your rc files. The install.sh script can be stored in your dotfiles directory, copied between computers, and so on.

---

## Let's wrap up

If you've followed along and have made it this far, congratulations! You now have a backup of all of your configuration files! 

If you started reading this, but thought, "Dang, I don't have any dotfiles to version, why am I reading this?", you're in luck! Since versioning one's dotfiles is a common practice, there are plenty of repositories out there for which you can choose to fork and start your own collection.

For example, if you were to checkout [my dotfiles](https://github.com/mhanberg/.dotfiles) you would find a pretty basic setup for [ruby](https://www.ruby-lang.org/en/) and [elixir](https://elixir-lang.org/) development, along with helpful configurations for [tmux](https://github.com/tmux/tmux/wiki) and [vim](http://www.vim.org/), which would be a good starting point if you didn't want to curate your dotfiles from scratch.
