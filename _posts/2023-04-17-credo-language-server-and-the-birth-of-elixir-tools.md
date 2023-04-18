---
layout: post
title: "Credo Language Server and the birth of elixir-tools"
date: 2023-04-17 01:00:00 -04:00
categories: post
permalink: /:title/
---

Last year I started working on [gen_lsp](https://github.com/mhanberg/gen_lsp), an abstraction for writing [language servers](https://microsoft.github.io/language-server-protocol/) in Elixir.

> I gave a presentation on gen_lsp and writing OTP process abstractions at CodeBEAM America 2022. You can watch my talk on [YouTube](https://www.youtube.com/watch?v=Ug-SEozyG1A).

Today I'd like to announce the release of the first language server built with `gen_lsp`.

## Credo Language Server

[Credo Language Server](https://github.com/elixir-tools/credo-language-server) is a persistent server that communicates with text editors via the Language Server Protocol.

This initial release comes with project wide diagnostics and a code action to add a `# credo:disable-for-next-line` magic comment above any Credo warning.

You can install it today using one of the `elixir-tools` family of editor extensions.

## elixir-tools

[elixir-tools](https://github.com/elixir-tools) is the new home for Credo Language Server and the aforementioned editor extensions.

### elixir-tools.nvim

If you write Elixir and use [Neovim](https://neovim.io), there is a chance you are already using my plugin, [elixir-tools.nvim](https://github.com/elixir-tools/elixir-tools.nvim) (formerly known as elixir.nvim).

The Neovim plugin has been renamed to help it better fit into it's place in the ecosystem and has given rise to the new elixir-tools family.

### elixir-tools.vscode

The elixir-tools family keeps on growing!

The release of Credo Language Server naturally mean that there would need to a way to use it with Visual Studio Code, so [elixir-tools.vscode](https://marketplace.visualstudio.com/items?itemName=elixir-tools.elixir-tools) was born.

This initial release brings support for Credo Language Server and Elixir filetype and highlighting support.

[ElixirLS](https://github.com/elixir-lsp/elixir-ls) support has been omitted since it can happily coexist along side elixir-tools.vscode. If there is demand to add ElixirLS support, that can be done, but at this time there is no need.

## Slow and Steady Wins the Race

Over the last 10 months I have been slowly chipping away at this project, making sure that every part is built with excellence in mind.

As I built out gen_lsp, I realized that the best way to achieve correctness was to generate most of the code from the official specification.

So, I built the [lsp_codegen](https://github.com/mhanberg/lsp_codegen) library.

It includes a handwritten generator that conforms to the LSP specification's [JSON Schema](https://json-schema.org) and is used to read the LSP metamodel and to generate Elixir code that includes typespecs and structs for all of the data structures.

While building the code generator, I realized that the specification's "Or" type was easy to represent using typespecs, but was actually hard to deserialize from a JSON payload into the Elixir data structures.

Inspired by [norm](https://github.com/elixir-toniq/norm) and my friend [Chris Keathley](https://keathley.io), I built [schematic](https://github.com/mhanberg/schematic). This allows me to fully validate, serialize, and deserialize complex data structures.

So, to build Credo Language Server, it just took 3 libraries, 2 editor extensions, and a conference talk. 😅

I will be writing more about gen_lsp and schematic in the future.

## What's Next

This is just the beginning! 🤗

I have some exciting ideas planned and can't wait to be able to share them with the Elixir community. If you'd like to stay on the bleeding edge of elixir-tools, feel free to join the [Discord](https://discord.gg/nNDMwTJ8).
