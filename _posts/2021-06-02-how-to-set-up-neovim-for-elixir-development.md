---
layout: post
title: "How to Set Up Neovim for Elixir Development"
date: 2021-06-02 09:00:00 -04:00
categories: post
permalink: /:title/
---

This article is the spiritual successor to [How to use Elixir LS with Vim](/post/2018/10/18/how-to-use-elixir-ls-with-vim/).

Since then, I've switched from Vim to the nightly release of [Neovim](https://github.com/neovim/neovim) as well as how I integrate linters, formatters, and LSPs.

This article will cover:

- Installing Neovim Nightly
- Getting started with the builtin LSP client
- Setting up Elixir LS
- Integrating [Credo](https://github.com/rrrene/credo)

_If you run into any problems with this guide, feel free to shoot me an [email](mailto:contact@mitchellhanberg.com)._

Let's get started!

## Installing Neovim Nightly

As of this writing, the builtin LSP client is only available on the nightly build of Neovim. Once 0.5 is released, you should be able to switch to a stable build, but for now, let's get nightly installed.

My preferred method for managing my installation of Neovim is to use [asdf](https://asdf-vm.com). You can install it with [Homebrew](https://brew.sh) as well, but I find asdf to be better.

For this article, I am going to assume you already have asdf installed, as it is the most prevalent way to manage Elixir and Erlang installations.

But we still need to install the Neovim asdf plugin.

```shell
$ asdf plugin add neovim
```

Listing the available versions demonstrates that we can install any previously released version of Neovim, as well as the nightly build. These versions are pre-built and downloaded as a GitHub release artifact. This makes installing them very fast.

```shell
$ asdf list all neovim
0.1.0
0.1.1
0.1.2
0.1.3
0.1.4
0.1.5
0.1.6
0.1.7
0.2.0
0.2.1
0.2.2
0.3.0
0.3.1
0.3.2
0.3.3
0.3.4
0.3.5
0.3.6
0.3.7
0.3.8
0.4.0
0.4.1
0.4.2
0.4.3
0.4.4
nightly
stable
```

If for some reason the nightly build cron job is on the fritz (as it sometimes is), you can also build form source with:

```shell
$ asdf install neovim ref:master
```

What we are going to stick with is:

```shell
$ asdf install neovim nightly
$ asdf global neovim nightly
```

Now, if you want to _update_ your nightly installation, all you have to do is uninstall and reinstall. I use the following as a convenient shell alias.

```shell
$ alias update-nvim-nightly='asdf uninstall neovim nightly && asdf install neovim nightly'
```

So, just to tie this all together, these are the steps you will go through to get Neovim nightly installed.

```shell
$ asdf plugin add neovim
$ asdf install neovim nightly
$ asdf global neovim nightly
$ echo "alias update-nvim-nightly='asdf uninstall neovim nightly && asdf install neovim nightly'" >> .zshrc # bash/fish/etc
```

## Getting started with the builtin LSP client

To help users get started with the LSP client, the Neovim team provides a plugin called [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig) that contains configurations for many common language servers.

There are also a few other plugins revolving around autocomplete that you'll need to install to get the full LSP experience.

With your preferred plugin manager, install the following plugins. I'm using [packer.nvim](https://github.com/wbthomason/packer.nvim). If you don't use a package manager, I suggest learning more about them by checking out packer.nvim as well as [vim-plug](https://github.com/junegunn/vim-plug).

```lua
vim.cmd [[packadd packer.nvim]]

local startup = require("packer").startup

startup(function(use)
  -- language server configurations
  use "neovim/nvim-lspconfig"

  -- autocomplete and snippets
  use "hrsh7th/nvim-compe"
  use "hrsh7th/vim-vsnip"
  use "hrsh7th/vim-vsnip-integ"
end)
```

Now that we have the required plugins installed, let's set them up so they get booted when we start Neovim. I am using the `init.lua` config file, but you can also add this to your `init.vim` if you use a lua heredoc.

```lua
local lspconfig = require("lspconfig")

-- Neovim doesn't support snippets out of the box, so we need to mutate the
-- capabilities we send to the language server to let them know we want snippets.
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true

-- Setup our autocompletion. These configuration options are the default ones
-- copied out of the documentation.
require "compe".setup {
  enabled = true,
  autocomplete = true,
  debug = false,
  min_length = 1,
  preselect = "disabled",
  throttle_time = 80,
  source_timeout = 200,
  incomplete_delay = 400,
  max_abbr_width = 100,
  max_kind_width = 100,
  max_menu_width = 100,
  documentation = true,
  source = {
    path = true,
    buffer = true,
    calc = true,
    vsnip = true,
    nvim_lsp = true,
    nvim_lua = true,
    spell = true,
    tags = true,
    treesitter = true
  }
}
```

That should be it for the basic LSP client configuration.

## Setting up Elixir LS

[Elixir LS](https://github.com/elixir-lsp/elixir-ls) is a tool that needs to be compiled from source, but it's pretty simple. Pick a directory to install and run the following commands.

```shell
$ git clone git@github.com:elixir-lsp/elixir-ls.git
$ cd elixir-ls && mkdir rel

# checkout the latest release if you'd like
$ git checkout tags/v0.7.0

$ mix deps.get && mix compile

$ mix elixir_ls.release -o release
```

Now that we have Elixir LS installed and compiled, let's get it set up in Neovim.

```lua
-- A callback that will get called when a buffer connects to the language server.
-- Here we create any key maps that we want to have on that buffer.
local on_attach = function(_, bufnr)
  local function map(...)
    vim.api.nvim_buf_set_keymap(bufnr, ...)
  end
  local map_opts = {noremap = true, silent = true}

  map("n", "df", "<cmd>lua vim.lsp.buf.formatting()<cr>", map_opts)
  map("n", "gd", "<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<cr>", map_opts)
  map("n", "dt", "<cmd>lua vim.lsp.buf.definition()<cr>", map_opts)
  map("n", "K", "<cmd>lua vim.lsp.buf.hover()<cr>", map_opts)
  map("n", "gD", "<cmd>lua vim.lsp.buf.implementation()<cr>", map_opts)
  map("n", "<c-k>", "<cmd>lua vim.lsp.buf.signature_help()<cr>", map_opts)
  map("n", "1gD", "<cmd>lua vim.lsp.buf.type_definition()<cr>", map_opts)

  -- These have a different style than above because I was fiddling
  -- around and never converted them. Instead of converting them
  -- now, I'm leaving them as they are for this article because this is
  -- what I actually use, and hey, it works ¯\_(ツ)_/¯.
  vim.cmd [[imap <expr> <C-l> vsnip#available(1) ? '<Plug>(vsnip-expand-or-jump)' : '<C-l>']]
  vim.cmd [[smap <expr> <C-l> vsnip#available(1) ? '<Plug>(vsnip-expand-or-jump)' : '<C-l>']]

  vim.cmd [[imap <expr> <Tab> vsnip#jumpable(1) ? '<Plug>(vsnip-jump-next)' : '<Tab>']]
  vim.cmd [[smap <expr> <Tab> vsnip#jumpable(1) ? '<Plug>(vsnip-jump-next)' : '<Tab>']]
  vim.cmd [[imap <expr> <S-Tab> vsnip#jumpable(-1) ? '<Plug>(vsnip-jump-prev)' : '<S-Tab>']]
  vim.cmd [[smap <expr> <S-Tab> vsnip#jumpable(-1) ? '<Plug>(vsnip-jump-prev)' : '<S-Tab>']]

  vim.cmd [[inoremap <silent><expr> <C-Space> compe#complete()]]
  vim.cmd [[inoremap <silent><expr> <CR> compe#confirm('<CR>')]]
  vim.cmd [[inoremap <silent><expr> <C-e> compe#close('<C-e>')]]
  vim.cmd [[inoremap <silent><expr> <C-f> compe#scroll({ 'delta': +4 })]]
  vim.cmd [[inoremap <silent><expr> <C-d> compe#scroll({ 'delta': -4 })]]
end

-- Finally, let's initialize the Elixir language server

-- Replace the following with the path to your installation
local path_to_elixirls = vim.fn.expand("~/.cache/nvim/lspconfig/elixirls/elixir-ls/release/language_server.sh")

lspconfig.elixirls.setup({
  cmd = {path_to_elixirls},
  capabilities = capabilities,
  on_attach = on_attach,
  settings = {
    elixirLS = {
      -- I choose to disable dialyzer for personal reasons, but
      -- I would suggest you also disable it unless you are well
      -- aquainted with dialzyer and know how to use it.
      dialyzerEnabled = false,
      -- I also choose to turn off the auto dep fetching feature.
      -- It often get's into a weird state that requires deleting
      -- the .elixir_ls directory and restarting your editor.
      fetchDeps = false
    }
  }
})
```

Elixir LS should be all set up now! Let's test it out by seeing if autocompletion, documentation on hover, and go to definition is working.

![Gif demonstration of autocomplete, documentation on hover, and go to definition](https://res.cloudinary.com/mhanberg/image/upload/v1621999434/elixir-ls-demo.gif){:standalone}

## Integrating Credo

I decided to completely remove [ALE](https://github.com/dense-analysis/ale), so I was wondering how I might get linters and formatters like credo and prettier hooked back in.

Luckly, there are a few projects that implement a language server for the purpose of running these tools for you. I am currently using [efm-langserver](https://github.com/mattn/efm-langserver).

I install efm with brew.

```shell
$ brew install efm-langserver
```

Once that is installed, let's hook it up to Neovim.

```lua
lspconfig.efm.setup({
  capabilities = capabilities,
  on_attach = on_attach,
  filetypes = {"elixir"}
})
```

And last, we need to teach efm how to speak Credo. Create a new file at `~/.config/efm-langserver/config.yaml`. Please note that we need to run Credo with `MIX_ENV=test` or else it's going to mess with Phoenix code reloading.

```yaml
version: 2

tools:
  mix_credo: &mix_credo
    lint-command: "MIX_ENV=test mix credo suggest --format=flycheck --read-from-stdin ${INPUT}"
    lint-stdin: true
    lint-formats:
      - '%f:%l:%c: %t: %m'
      - '%f:%l: %t: %m'
    lint-category-map:
      R: N
      D: I
      F: E
      W: W
    root-markers:
      - mix.lock
      - mix.exs

languages:
  elixir:
    - <<: *mix_credo
```

Now you should be seeing Credo checks showing up inside Neovim.

## My Setup

If you would like to check out my actual dotfiles, feel free to check them out on [GitHub](https://github.com/mhanberg/.dotfiles).

I've extracted quite a few helper modules and functions that make organizing my plugins a little easier.

Enjoy!
