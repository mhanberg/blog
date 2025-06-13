---
layout: Blog.PostLayout
title: "Modern Format on Save in Neovim"
date: 2024-03-14 08:00:00 EST
categories: post
permalink: /:title/
tags: [neovim, dx, dotfiles, tips]
---

Formatting on save is a popular workflow and is built into many text editors and IDEs.

In Neovim, you must create this manually, but it is very easy using `autocmds`.

```lua
-- 1
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("lsp", { clear = true }),
  callback = function(args)
    -- 2
    vim.api.nvim_create_autocmd("BufWritePre", {
      -- 3
      buffer = args.buf,
      callback = function()
        -- 4 + 5
        vim.lsp.buf.format {async = false, id = args.data.client_id }
      end,
    })
  end
})
```

1. We create a new `autocmd` that fires on the `LspAttach` event. This event is fired when an LSP client attaches to a buffer. In this `autocmd`, you can easily set configuration that is specific to that buffer and LSP client.
2. We create another `autcmd` inside the `LspAttach` callback, this time for the `BufWritePre` event. This fires when you save the buffer but before it flushes anything to disk. This gives you a chance to manipulate the buffer first.
3. We configure this `autocmd` to only execute for the current buffer. This is a little more straight forward rather than setting an `autocmd` that executes for any range of file types.
4. In the callback, we run `vim.lsp.buf.format` to format the buffer, with the flag `async = false`. This ensures that the formatting request will block until it completes, so that it completely finishes formatting before flushing the file to disk.
5. We also set the `id = args.data.client` flag so that the formatting request is only sent to the LSP client that is related to the outer `LspAttach` request. This ensures that we aren't running the formatting request multiple times in case the buffer is attached to multiple LSPs.

And there we have it, modern format on save for those who want it.
