---
layout: Blog.PostLayout
title: How to use Elixir LS with Vim
date: 2018-10-18 08:00:00 EST
updated: 2020-06-19 08:00:00 EST
categories: post
desc: Guide on how to use the Elixir LS language server with the Vim text editor. 
tags: [elixir, programming, lsp, vim, neovim, tips]
permalink: /:categories/:year/:month/:day/:title/
---

## What is Elixir LS?

[Elixir LS](https://github.com/elixir-lsp/elixir-ls) by Jake Becker (now maintained by the [elixir-lsp](https://github.com/elixir-lsp) organization) is the language server implementation for Elixir.

## What is a language server?

If you've been following the story of [Visual Studio Code](https://code.visualstudio.com), there is a chance you've heard of another recent creation from Microsoft: the [Language Server Protocol](https://langserver.org). 

> The Language Server Protocol (LSP) defines the protocol used between an editor or IDE and a language server that provides language features like auto complete, go to definition, find all references etc.

This allows creators to build universal "language servers" that can be used by any text editor. 

## How to integrate with Vim

Using a language server requires a client implementation for your editor and we are going to use [ALE](https://github.com/dense-analysis/ale) by dense-analysis.

If you're using [vim-plug](https://github.com/junegunn/vim-plug) you can install ALE by adding the following to your `.vimrc` and running `:PlugInstall`. Otherwise, consult your plugin manager's documentation.

```vim
" .vimrc

call plug#begin('~/.vim/bundle')
...
Plug 'dense-analysis/ale'
call plug#end()
```
Now let's install Elixir LS!

```shell
$ git clone git@github.com:elixir-lsp/elixir-ls.git
$ cd elixir-ls && mkdir rel

# checkout the latest release
$ git checkout tags/v0.4.0

$ mix deps.get && mix compile

$ mix elixir_ls.release -o rel
```

Perfect, our final step is to configure ALE to use Elixir LS.

```vim
" .vimrc

" Required, explicitly enable Elixir LS
let g:ale_linters.elixir = ['elixir-ls']

" Required, tell ALE where to find Elixir LS
let g:ale_elixir_elixir_ls_release = expand("<path to your release>")

" Optional, you can disable Dialyzer with this setting
let g:ale_elixir_elixir_ls_config = {'elixirLS': {'dialyzerEnabled': v:false}}

" Optional, configure as-you-type completions
set completeopt=menu,menuone,preview,noselect,noinsert
let g:ale_completion_enabled = 1
```

## Now what?

I would familiarize yourself with the [features of ALE](https://github.com/dense-analysis/ale#usage) and decide how you want to incorporate them into your workflow. ALE doesn't prescribe any keymappings, so feel free to experiment to see what works best for you!

Check out my [.vimrc](https://github.com/mhanberg/.dotfiles/blob/fb9831367e5543aa84df15b0d1b08e8993c6a905/vimrc#L203..L232) to see how I use ALE.
