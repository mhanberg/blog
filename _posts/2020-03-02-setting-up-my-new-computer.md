---
layout: post
title: Setting up my new computer
date: 2020-03-02 09:00:00 -05:00
categories: post
permalink: /:title/
img: https://images.unsplash.com/photo-1496181133206-80ce9b88a853?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=2551&q=80
---

I started a new job last week, so I naturally received a new computer that required some set up.

Usually this could take hours or even days, as there's always an app I forget to download or some random setting that I can't remember how to configure.

Luckily, I have automated most of the process! In my [dotfiles](https://github.com/mhanberg/.dotfiles) repository, I wrote (some parts [borrowed](https://github.com/thoughtbot/laptop)) a shell script to install all of my CLI and GUI tools for me, as well as configure my shell environment.

Installing everything still took at least an hour (the bulk of this is due to `brew` compiling packages from source), but at least I am able to do it by running only a few shell commands!

## My Process

- [Create a new ssh key](https://help.github.com/en/github/authenticating-to-github/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent) and upload the public key to my Github profile.
- Install the Xcode Command Line Tools (`xcode-select --install`). This is necessary to be able to use `git`. 
- Clone my dotfiles into my home directory `git clone git@github.com:mhanberg/.dotfiles.git && cd .dotfiles`
- Run the install script `./install`
- Watch as my computer magically bootstraps itself 😄.

This is all made possible by [Homebrew](https://brew.sh) and [rcm](https://github.com/thoughtbot/rcm).

## ./install

The `install` script installs Homebrew and then runs the command `brew bundle`. The `bundle` subcommand will install every package that is declared in the `Brewfile` that is located in the root of my dotfiles.

An awesome thing about Homebrew is that it can install GUI tools (Firefox, Postico, Slack) in addition to CLI developer tools.

You can hand-craft a `Brewfile` or generate one based on the current packages and casks you have installed using `brew bundle dump`. 

So far I haven't found a good way to keep my `Brewfile` up to date. I think that there might be a way to hook into your shell to print a message every time you install something using `brew install`.

The script then switches the default shell to the `zsh` that is installed by `brew` (if it isn't already). `zsh` is the default shell on macOS now, but if you want to use the newest releases you'll want to install via `brew`.

```bash
#! /usr/bin/env bash

set -e

if ! command -v brew >/dev/null; then
  echo "==> Installing Homebrew ..."
  if [[ "$OSTYPE" = darwin* ]]; then
    curl -fsS 'https://raw.githubusercontent.com/Homebrew/install/master/install' | ruby
  else
    curl -fsSL 'https://raw.githubusercontent.com/Linuxbrew/install/master/install.sh' | sh -c
  fi
fi

echo "==> Install Homebrew dependencies"
brew bundle

update_shell() {
  local shell_path;
  shell_path="$(command -v zsh)"

  echo "==> Changing your shell to zsh ..."
  if ! grep "$shell_path" /etc/shells > /dev/null 2>&1 ; then
    echo "==> Adding '$shell_path' to /etc/shells"
    sudo sh -c "echo $shell_path >> /etc/shells"
  fi
  sudo chsh -s "$shell_path" "$USER"
}

case "$SHELL" in
  */zsh)
    if [ "$(command -v zsh)" != '/usr/local/bin/zsh' ] ; then
      echo "==> Updating shell to ZSH"
      update_shell
    fi
    ;;
  *)
    echo "==> Updating shell to ZSH"
    update_shell
    ;;
esac

./rcup
```

## ./rcup

And finally, we run my `rcup` wrapper script. This calls the `rcup` utility included with `rcm`, with a few options that I want to always use, such as ignoring certain files.

`rcm` is a set of utilities that help manage your dotfiles using symlinks. When I call `rcup`, it will make symlinks in my home directory for any files (other than those I tell it to ignore) in `~/.dotfiles`.

When adding a new dotfile, I can either create it in my home directory and call `mkrc .my-new-dotfile` or I can create it in `~/dotfiles/` and run `~/.dotfiles/rcup` once more.

```bash
#! /usr/bin/env bash

set -e

echo "==> Installing dotfiles"
rcup -U Brewfile -x README.md -x mitch-preonic.json -x install -x rcup -v
```

## Room for improvement

My install script automates _most_ things, but there are still some places optimize.

- Automate the manual steps with a "curl to bash" script that installs XCode and clones my dotfiles. e.g. `curl https://raw.githubusercontent.com/mhanberg/.dotfiles/master/bootstrap.sh | bash`.
- Create a new ssh key.
- Configure macOS specific settings like key repeat speed, dock size/behavior, etc.
- Install my `zsh` plugins with [zplug](https://github.com/zplug/zplug).
