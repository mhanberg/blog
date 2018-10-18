---
layout: post
title: How to use Elixir LS with Vim
date: 2018-10-07 09:00:00 -04:00
categories: post
desc: Guide on how to use the Elixir LS language server with the Vim text editor. 
permalink: /:categories/:year/:month/:day/:title/
---

### What is Elixir LS?

[Elixir LS](https://github.com/JakeBecker/elixir-ls) by Jake Becker is the language server implementation for Elixir.

### What is a language server?

If you've been following the story of [Visual Studio Code](https://code.visualstudio.com), there is a chance you've heard of another recent creation from Microsoft: the [Language Server Protocol](https://langserver.org). 

>The Language Server Protocol (LSP) defines the protocol used between an editor or IDE and a language server that provides language features like auto complete, go to definition, find all references etc.

This allows creators to build universal "language servers" that can be used by any text editor. 

### How to integrate with Vim

Using a language server requires a client implementation for your editor and we are going to use [ALE](https://github.com/w0rp/ale) by w0rp.

If you're using [vim-plug](https://github.com/junegunn/vim-plug) you can install ALE by adding the following to your `.vimrc` and running `:PlugInstall`. Otherwise, consult your plugin manager's documentation.

```vim
" .vimrc

call plug#begin('~/.vim/bundle')
...
Plug 'w0rp/ale'
call plug#end()
```
Now let's install Elixir LS!

```shell
$ git clone git@github.com:JakeBecker/elixir-ls.git
$ cd elixir-ls && mkdir rel

$ mix deps.get && mix compile

$ mix elixir_ls.release -o rel
```

Perfect, our final step is to tell vim where our Elixir LS instance lives.

```vim
" .vimrc

let g:ale_elixir_elixir_ls_release = '<your path to elixir-ls>/rel'
```

### Now what?

I would familiarize yourself with the [features of ALE](https://github.com/w0rp/ale#usage) and decide how you want to incorporate them into your workflow. ALE doesn't prescribe any keymappings, so feel free to experiment to see what works best for you!

Check out my [.vimrc](https://github.com/mhanberg/.dotfiles/blob/master/vimrc#L97) to see how I use ALE.
