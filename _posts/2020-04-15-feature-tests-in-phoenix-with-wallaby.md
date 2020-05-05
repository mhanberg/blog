---
layout: post
title: "Feature Tests in Phoenix with Wallaby"
date: 2020-04-15 09:00:00 -04:00
categories: post
permalink: /:title/
---

## What's New in Wallaby v0.24.0

This latest update brings improvements to the overall developer experience with Wallaby. Writing feature tests has never been easier!

Utilizing the same approach as libraries like [PropCheck](https://github.com/alfert/propcheck) and [StreamData](https://github.com/whatyouhide/stream_data), Wallaby provides an alternative testing macro, `feature/2`.

A small example looks something like this.

```elixir
defmodule MyAppWeb.LoginFeatureTest do
  use ExUnit.Case, async: true
  use Wallaby.Feature

  feature "a user can log in", %{session: session} do
    session
    |> visit("/login")
    |> fill_in(Query.text_field("Username"), with: "mhanberg")
    |> fill_in(Query.text_field("Password"), with: "P@ssw0rd!")
    |> click(Query.button("Login"))
    |> assert_text("Success!")
  end
end
```

### Automatic Session Creation

`Wallaby.Feature` reduces boilerplate by automatically creating sessions and checking out Ecto repos. You no longer need to copy/paste the example ExUnit case template from the README.

This requires a new configuration option if you are using Ecto, but no longer requires the setup block.

#### After

```elixir
# In your test module
use Wallaby.Feature

# config/test.exs if you are using Ecto

config :wallaby, otp_app: :your_app
```


### Improved Automatic Screenshots
