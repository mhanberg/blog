---
layout: post
title: "How EEx Turns Your Template Into HTML"
date: 2022-04-11 01:00:00 -04:00
categories: post
permalink: /:title/

---

EEx is a templating language and module built into the [Elixir](https://hexdocs.pm/eex/EEx.html) standard library, often used by web servers to render dynamic content for a web application. The same concept exists in other language ecosystems, ERB for Ruby, Blade for Laravel/PHP, Pug/Jade for JavaScript.

A couple features of EEx that make it stand out are:

- Templates can be compiled into functions ahead of time, avoiding needing to read from the file system at runtime. 
- EEx has the concept of an "Engine" allowing you to compile an existing template into something different than what the builtin engine, [`EEx.SmartEngine`](https://hexdocs.pm/eex/EEx.SmartEngine.html), does. This is what [Phoenix LiveView](https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.html) does.

Recently, [José Valim tweeted me some advice on how to use the EEx Engine](https://twitter.com/josevalim/status/1511348149323014155?s=20&t=sFyaicmJApbs5yQO-n_CIA) in my library [Temple](https://github.com/mhanberg/temple) (an alternative HTML library, that uses an Elixir DSL). At first I was very confused at José's suggestion; I don't want to write EEx at all! I want Temple to go from DSL straight to `iolist` or `%LiveView.Rendered{}` structs.

Luckily, my coworker [Marlus Saraiva](https://twitter.com/MarlusSaraiva) messaged me and gave a bit more context on Josés suggestion, and suddenly it all clicked!. (Hopefully at the end of this post, you'll understand how José's suggestion makes perfect sense and was extremely clear.)

This conversation led me to ask myself, how does EEx work anyway? I decided to source dive EEx, LiveView, [Surface](https://surface-ui.org/), and [HEEx](https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.Helpers.html#sigil_H/2-syntax) and will share with you what I learned!

## The Source Code

Technically EEx is just a templating syntax that can handle any plaintext format. It doesn't matter if its HTML, JavaScript, or even Elixir (this is how the Phoenix generators work).

EEx templates allow you to execute arbitrary Elixir code inside of special tags and inject the runtime result into the return value. You can use single expressions or even expressions that take blocks. The `EEx.SmartEngine` also allows you to ergonomically access data passed to the template with the `@` syntax.

```eex
<!-- single line expression -->
<span><%= @user.name %></span>

<!-- block expression -->
<ul>
  <%= for user <- @users do %>
    <li><%= user.name %></li>
  <% end %>
</ul>
```

## The Compiler

The public API for compiling an EEx file or string consists of the `EEx.compile_file/2` and `EEx.compile_string/2` functions. Internally, they will call into the `EEx.Compiler` module.

The `EEx.Compiler` module is where the coordination happens when compiling our source code. You can find the source code [here](https://github.com/elixir-lang/elixir/blob/v1.13.3/lib/eex/lib/eex/compiler.ex).

This module's `compile/2` function is responsible for calling the tokenizer, traversing them, and passing them to the appropriate callbacks on the engine. By default, EEx uses the builtin `EEx.SmartEngine`.

Essentially there are two steps:

1. Turn the source into tokens.
2. Turn the tokens into Elixir AST by passing them to the relevant callback on the given `EEx.Engine`.

## The Tokenizer

The first thing that the compiler will do is tokenize the content. You can find the source code [here](https://github.com/elixir-lang/elixir/blob/v1.13.3/lib/eex/lib/eex/tokenizer.ex).

This translates the source code into a list of Elixir terms that describe the tokens found in the document. The above example will be tokenized into the following.

```elixir
{:ok,
 [
   {:text, 0, 0, '<!-- single line expression -->\n<span>'},
   {:expr, 1, 7, '=', ' @user.name '},
   {:text, 1, 24, '</span>\n\n<!-- block expression -->\n<ul>\n'},
   {:start_expr, 5, 3, '=', ' for user <- @users do '},
   {:text, 5, 31, '\n    <li>'},
   {:expr, 6, 9, '=', ' user.name '},
   {:text, 6, 25, '</li>\n'},
   {:end_expr, 7, 3, [], ' end '},
   {:text, 7, 12, '\n</ul>\n'},
   {:eof, 9, 1}
 ]}
```

The list of tokens are fairly self explanatory. We can see `:text` tokens for static ranges of plain text, `:expr` tokens for single line expressions, and `:start_expr`/`:end_expr` tokens for the multi-line do/end block expression.

The tokens also include some row/column metadata, which is helpful later on for attributing error messages to the origin point in the source code.

Now that we have the tokens, we need to traverse over them and pass them into the engine.

## The Engine

The engine is where the magic happens! It's responsible for building the tokens into usable Elixir AST, which can then be injected into a function.

An `EEx.Engine` has the following callbacks that it must implement and that your compiler must call appropriately. I'll copy/paste some of the callback documentation here, copyright belonging to the elixir-lang/elixir project.

```elixir
@doc """
Called at the beginning of every template.
It must return the initial state.
"""
@callback init(opts :: keyword) :: state

@doc """
Called at the end of every template.
It must return Elixir's quoted expressions for the template.
"""
@callback handle_body(state) :: Macro.t()

@doc """
Called for the text/static parts of a template.
It must return the updated state.
"""
@callback handle_text(state, [line: pos_integer, column: pos_integer], text :: String.t()) ::
            state

@doc """
Called for the dynamic/code parts of a template.
The marker is what follows exactly after `<%`. For example,
`<% foo %>` has an empty marker, but `<%= foo %>` has `"="`
as marker. The allowed markers so far are:
  * `""`
  * `"="`
  * `"/"`
  * `"|"`
Markers `"/"` and `"|"` are only for use in custom EEx engines
and are not implemented by default. Using them without an
appropriate implementation raises `EEx.SyntaxError`.
It must return the updated state.
"""
@callback handle_expr(state, marker :: String.t(), expr :: Macro.t()) :: state

@doc """
Invoked at the beginning of every nesting.
It must return a new state that is used only inside the nesting.
Once the nesting terminates, the current `state` is resumed.
"""
@callback handle_begin(state) :: state

@doc """
Invokes at the end of a nesting.
It must return Elixir's quoted expressions for the nesting.
"""
@callback handle_end(state) :: Macro.t()
```

The compiler will start by calling the `c:init` callback to initialize the engine's state. It will pass this state to the various other callbacks as required. The state is an implementation detail to the Engine but will usually collect the static and dynamic pieces of the template as it traverses the tokens.

Whenever the compiler encounters a "text" token, it will pass the state, the metadata, and the text to he `c:handle_text/3` callback.

Whenever the compiler encounters an `expression` token, it will pass the state, the "marker", and the expression AST to the `c:handle_expr/3` callback.

If the encountered expression is multi-line, it will call the `c:handle_begin/3` callback. This creates a new "nesting" and will return a brand new state to be used to collect the output for the "nested" tokens.

When the compiler encounters an `:eof` token, it knows the template has finished and passes the state to `c:handle_body`, which returns the Elixir AST for the entire template.

I built an app that allows you to step through the compilation of a template as it traverses the tokens to help visualize what is happening and the output that is produced.

![EEx Compiler Visualizer](https://user-images.githubusercontent.com/5523984/162604950-a682e940-2af2-4968-886b-7413f256020d.gif){:standalone}

You should check it out [here](https://github.com/mhanberg/eex_compiler_visualizer).

Here is what the compiled output for the above example looks like.

The AST generated by the `EEx.SmartEngine` forms all dynamic parts of your template into variables, then at the end, creates a `bitstring` with the result.

```elixir
arg0 = String.Chars.to_string(EEx.Engine.fetch_assign!(var!(assigns), :user).name)

arg1 =
  String.Chars.to_string(
    for user <- EEx.Engine.fetch_assign!(var!(assigns), :users) do
      arg1 = String.Chars.to_string(user.name)
      <<"\n    <li>", arg1::binary, "</li>\n  ">>
    end
  )

<<"<!-- single line expression -->\n<span>", arg0::binary,
  "</span>\n\n<!-- block expression -->\n<ul>\n  ", arg1::binary, "\n</ul>">>
```

Let's take a look at how the `Phoenix.HTML.Engine` compiles the same template.

We can observe some similarities: it has the same `@` assigns functionality and it groups dynamic pieces into variables to coordinate later into the final result.

It also packs in some extra features!

- It will escape dynamically rendered plaintext, so you won't accidentally get some JS injection.
- It can pass data through the `Phoenix.HTML.Safe` protocol, allowing you to make custom representation of your Elixir data structures.
- It builds the result into `iodata` instead of a `bitstring`.

```elixir
arg0 =
  case Phoenix.HTML.Engine.fetch_assign!(var!(assigns), :user).name do
    {:safe, data} -> data
    bin when is_binary(bin) -> Phoenix.HTML.Engine.html_escape(bin)
    other -> Phoenix.HTML.Safe.to_iodata(other)
  end

arg1 =
  case (for user <- Phoenix.HTML.Engine.fetch_assign!(var!(assigns), :users) do
          arg1 =
            case user.name do
              {:safe, data} -> data
              bin when is_binary(bin) -> Phoenix.HTML.Engine.html_escape(bin)
              other -> Phoenix.HTML.Safe.to_iodata(other)
            end

          {:safe, ["\n    <li>", arg1, "</li>\n  "]}
        end) do
    {:safe, data} -> data
    bin when is_binary(bin) -> Phoenix.HTML.Engine.html_escape(bin)
    other -> Phoenix.HTML.Safe.to_iodata(other)
  end

{:safe,
 [
   "<!-- single line expression -->\n<span>",
   arg0,
   "</span>\n\n<!-- block expression -->\n<ul>\n  ",
   arg1,
   "\n</ul>"
 ]}
```

Let's also peek at the output of `Phoenix.LiveView.Engine`, as it will generate something fairly different than the previous two engines.

The LiveView engine will emit these `%Rendered{}` and `%Comprehension{}` structs that allow it to efficiently do its diff tracking.

```elixir
require Phoenix.LiveView.Engine

(
  dynamic = fn track_changes? ->
    changed =
      case assigns do
        %{__changed__: changed} when track_changes? -> changed
        _ -> nil
      end

    (
      v0 =
        case Phoenix.LiveView.Engine.nested_changed_assign?(assigns, changed, :user, struct: :name) do
          true -> Phoenix.LiveView.Engine.live_to_iodata(assigns.user.name)
          false -> nil
        end

      v2 =
        case Phoenix.LiveView.Engine.changed_assign?(changed, :users) do
          true ->
            %Phoenix.LiveView.Comprehension{
              static: ["\n    <li>", "</li>\n  "],
              dynamics:
                for user <- assigns.users do
                  v1 = Phoenix.LiveView.Engine.live_to_iodata(user.name)
                  [v1]
                end,
              fingerprint: 245_710_792_584_248_035_419_893_716_549_685_965_177
            }

          false ->
            nil
        end
    )

    [v0, v2]
  end

  %Phoenix.LiveView.Rendered{
    static: [
      "<!-- single line expression -->\n<span>",
      "</span>\n\n<!-- block expression -->\n<ul>\n  ",
      "\n</ul>"
    ],
    dynamic: dynamic,
    fingerprint: 104_434_365_286_405_865_087_616_174_532_871_347_220,
    root: nil
  }
)
```

## How can this help Temple?

So far we've detailed how _Elixir_ will compile an EEx template. The `EEx.Tokenizer` and `EEx.Compiler` are not public modules and are essentially an implementation detail.

Surface and HEEx are not EEx compatible, so attempting to compile them with `EEx.compile_string/2` would raise a syntax error. So how do they work?

They both implement their own tokenizer and compiler but delegate to the engine! Temple can do the exact same thing.

The _Engine_ is the public API that Temple can leverage to efficiently output Elixir AST for the various compile targets: Non-Phoenix web apps (for use in Plug, [Aino](https://github.com/oestrich/aino), any non-Phoenix web framework), traditional Phoenix Apps, and Phoenix LiveView apps. This is the technique that José was explaining that HEEx and Surface use.

Here is a table comparing which parts of the "template to Elixir AST" lifestyle between the builtin EEx compiler, the Temple compiler (in a theoretical future when Temple leverages this technique), Surface, and HEEx. EEx and HEEx don't have their own AST, so the parser step is not applicable.

| Step | EEx | Temple | Surface | HEEx |
|-------------------------------|
| Tokenizer | EEx.Tokenizer | Kernel.SpecialForms.quote/2 | Surface.Compiler.Tokenizer | Phoenix.LiveView.HTMLTokenizer |
| Parser | - | Temple.Parser | Surface.Compiler.Parser | - |
| "Compiler" | EEx.Compiler | Temple.Renderer | Surface.Compiler.EExEngine | Phoenix.LiveView.HTMLEngine | 
| Engine | Chosen Engine | Chosen Engine | Phoenix.LiveView.Engine | Chosen Engine |

Prior to this revelation, I had planned on the monumental task of basically re-implementing the `EEx.SmartEngine`, `Phoenix.HTML.Engine`, and `Phoenix.LiveView.Engine` modules in Temple (probably with lots of bugs). Now that I understand how to utilize the existing engines properly, it should be a relatively small lift for Temple to be able to use all three of them!

🎉 Kudos to José and Marlus for the advice, I really appreciate it!
