---
layout: Blog.PostLayout
title: "Create Your Own Neovim Distribution"
date: 2024-06-05 01:00:00 EST
permalink: /:title/
tags: [tips, neovim]
---

Gotcha! The click bait worked!

We're not really in the market to create an actual "distribution", but we are going to explore how to extract your Neovim configuration into it's own plugin.

Other real distributions actually employ this trick themselves like [LazyVim](https://github.com/LazyVim/LazyVim) and [AstroVim](https://github.com/astronvim/astronvim), the main requirement is that you use the [lazy.nvim](https://github.com/folke/lazy.nvim) package manager.

Let's get into the code!

## Converting your current configuration

Converting your configuration into a plugin is mostly just renaming some files/directories and moving them into their own repo.

### Original Configuration

Your original configuration might look something like this, you have a folder that handles your lazy.nvim plugin specs, some custom modules, some ftplugins, and a normal `init.lua`.

```
$HOME/.config/nvim/
└── lua/
    ├── custom/
    │   ├── plugins/
    │   │   ├── init.lua
    │   │   ├── elixir.lua
    │   │   └── lsp.lua
    │   ├── terminal.lua
    │   └── treesitter.lua
    ├── ftplugin/
    │   ├── elixir.lua
    │   └── javascript.lua
    └── init.lua
```

### Plugin based Configuration

The steps I took to extract my distribution was to:

- move the whole thing to a new git repository.
- rename `custom` to `mydistro` and resolve any necessary changes.
- rename `init.lua` to `plugin/mydistro.lua`.

Your new configuration structure should look like this:

```
$HOME/
├── .config/nvim/
│   └── init.lua
└── mydistro/
    └── lua/
        ├── custom/
        │   ├── plugins/
        │   │   ├── init.lua
        │   │   ├── elixir.lua
        │   │   └── lsp.lua
        │   ├── terminal.lua
        │   └── treesitter.lua
        ├── ftplugin/
        │   ├── elixir.lua
        │   └── javascript.lua
        └── plugin/
            └── mydistro.lua
```

### init.lua

The `init.lua` file in your dotfiles should look like this:

```lua
-- bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim
    .system({
      "git",
      "clone",
      "--filter=blob:none",
      "https://github.com/folke/lazy.nvim.git",
      "--branch=stable", -- latest stable release
      lazypath,
    })
    :wait()
end

vim.opt.rtp:prepend(lazypath)
require("lazy").setup {
  spec = {
    {
      "myname/mydistro", -- the location on GitHub for our distro
      dev = true, -- tells lazy.nvim to actually load a local copy
      import = "mydistro.plugins" -- the path to your plugins lazy plugin spec
    },
  },
  dev = { path = "~" }, -- the path to where `dev = true` looks for local plugins
  install = {
    missing = true,
  },
}
```

And we're done!

## Why?

Well, one: for fun!

And two: I personally use [home-manager](https://github.com/nix-community/home-manager) to manage my dotfiles, but that requires running home-manager anytime you change them.

This is very annoying when it comes to tweaking your Neovim configuration, so moving my configuration to a plugin that lives outside of home-manager means I can iterate quicker.

Another hypothetical use case is making it easier for someone to try out your Neovim configuration. This could be for someone getting into Neovim for the first time, or perhaps a plugin author trying to help debug an issue you're having.

Happy hacking!
