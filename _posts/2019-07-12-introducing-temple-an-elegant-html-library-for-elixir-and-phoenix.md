---
layout: post
title: Introducing Temple&#58; An elegant HTML library for Elixir and Phoenix
date: 2019-07-12 09:00:00 -04:00
categories: post
permalink: /:title/
---

![Logo for the Elixir library Temple]({{ 'images/temple.png' | absolute_url }}){: class="mx-auto my-16 bg-transparent" style="filter: invert(100%);"}

Temple is a macro DSL for writing HTML markup in [Elixir](https://elixir-lang.org) and a template engine for [Phoenix](https://phoenixframework.org/).

Conventional template languages like [EEx](https://hexdocs.pm/eex/EEx.html) use a form of interpolation to embed a programming language into a markup language, which can result in some ugly code that can be difficult to write and debug.

Temple is written using _pure_ elixir.

Let's take a look.

```elixir
use Temple

@items ["eggs", "milk", "bacon"]

temple do
  h2 "todos"

  ul class: "list" do
    for item <- @items do
      li class: "item" do
        div class: "checkbox" do
          div class: "bullet hidden"
        end

        div item
      end
    end
  end

  script """
  function toggleCheck({currentTarget}) {
    currentTarget.children[0].children[0].classList.toggle("hidden");
  }

  let items = document.querySelectorAll("li");

  Array.from(items).forEach(checkbox =>
    checkbox.addEventListener("click", toggleCheck)
  );
  """
end
```

### Phoenix Template Engine

By implementing the `Phoenix.Template.Engine` behaviour, Temple becomes a full fledged template engine.

```elixir
# config/config.exs

config :phoenix, :template_engines, exs: Temple.Engine
```

```elixir
# lib/blog_web.ex

def view do
  quote do
    # ...

    use Temple
  end
end
```

```elixir
# lib/blog_web/templates/post/show.html.exs

h2 @post.title

div do
  text "By #{Enum.join(@post.authors, ", ")}"
end

article do
  text @post.body
end

aside do
  for c <- @post.comments do
    div c.name
    div c.body
  end
end
```

### Phoenix.HTML

All of the Phoenix form and link helpers have been wrapped to be compatible with Temple.

The semantics and naming of some helpers have been change to work as macros and avoid name conflicts with standard HTML5 tags.

```elixir
# takes a block and has access to the variable `form`
form_for @post, Routes.post_path(@conn, :create) do

  # prefixed with `phx_` to avoid a conflict with the <label> tag
  phx_label form, :title
  text_input form, :title

  phx_label form, :authors
  multiple_select form, :authors, @users

  phx_label form, :body
  text_area form, :body
end
```

### Components

Temple offers [React-ish](https://reactjs.org) style API for extracting reusable components. 

`defcomponent` will define macros for you to use in your markup without them looking any different from normal tags.

```elixir
# layout_view.ex

defmodule MyAppWeb.LayoutView do
  use MyAppWeb, :view

  defcomponent :nav_item do
    div id: @id, class: "flex flex-col" do
      div @name, class: "margin-bottom-2"
      div @description
    end
  end
end

# app.html.exs

html do
  head do
    # stuff
  end

  body do
    header do
      nav do
        for item <- @nav_items do
          nav_item id: item.key,
                   name: item.name,
                   description: item.description
        end
      end
    end

    main role: "main", class: "container" do
      p get_flash(@conn, :info), class: "alert alert-info", role: "alert"
      p get_flash(@conn, :error), class: "alert alert-danger", role: "alert"

      partial render(@view_module, @view_template, assigns)
    end
  end
end
```

Components can also take children if passed a block and are accessed via the `@children` variable.

```elixir
defcomponent :takes_children do
  div class: "some-wrapping-class" do
    @children
  end
end

takes_children do
  span do
    text "child one"
  end
  span do
    text "child two"
  end
  span do
    text "child three"
  end
end

# <div class="some-wrapping-class">
#   <span>child one</span>
#   <span>child two</span>
#   <span>child three</span>
# </div>
```

## Wrapping up

If you're interested in using Temple, you can install it from [Hex](https://hex.pm/packages/temple) and check it out on [GitHub](https://github.com/mhanberg/temple).

Let me know what you think!
