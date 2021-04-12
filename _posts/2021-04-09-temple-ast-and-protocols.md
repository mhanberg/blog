---
layout: post
title: "Temple, AST, and Protocols"
date: 2021-04-12 10:00:00 -04:00
categories: post
permalink: /:title/
---

As [Temple](https://github.com/mhanberg/temple) has aged, my ambition for this little library has grown.

Temple started with the ability to produce HTML at runtime, but now includes:

- EEx output target
- LiveView support (it's just EEx after all!)
- Basic component functionality (essentially just partials)

If my goals for this project are going to evolve, so does the code base. So far I've been able to accomplish this with a rather naive and imperative compilation process.

I figured that writing an actual abstract syntax tree (AST) as an intermediate format (IF) would be the next step, and along that journey I also found a nice use case for a [protocol](https://elixir-lang.org/getting-started/protocols.html).

Before we look at the new AST, let's go over how things used to work.

The previous method would recursively traverse Elixir AST, storing the collected tokens in a global buffer (backed by an [Agent](https://hexdocs.pm/elixir/Agent.html)).

```elixir
buffer = Agent.start_link(fn -> [] end)

Utils.traverse(ast, buffer)

markup =
  buffer
  |> Agent.get(fn buf -> buf end)
  |> Enum.reverse()
  |> Enum.join("\n")
```

The `Utils.traverse/2` function would call a certain parser based on the Elixir AST with which it was working. The parser that would be invoked for lines that include anonymous functions looked something like this.

```elixir
{_do_and_else, args} =
  args
  |> Utils.split_args()

{args, func_arg, args2} = Utils.split_on_fn(args, {[], nil, []})

{func, _, [{arrow, _, [[{arg, _, _}], block]}]} = func_arg

Agent.update(buffer, fn buf ->
  markup = "<%= " <>
           to_string(name) <>
           " " <>
           (Enum.map(args, &Macro.to_string(&1)) |> Enum.join(", ")) <>
           ", " <>
           to_string(func) <>
           " " <>
           to_string(arg) <>
           " " <>
           to_string(arrow) <>
           " %>"

  [markup | buf]
end)

Agent.update(fn buf -> ["\n" | buf] end)

Utils.traverse(buffer, block)

if Enum.any?(args2) do
  post_fn_args =
    args2
    |> Enum.map(fn arg -> Macro.to_string(arg) end)
    |> Enum.join(", ")

  Agent.update(fn buf ->
    ["<% end, " <> post_fn_args <> " %>" | buf]
  end)

  Agent.update(fn buf -> ["\n" | buf] end)
else
  Agent.update(fn buf -> ["<% end %>" | buf] end)
  Agent.update(fn buf -> ["\n" | buf] end)
end
```

This code illustrates that I am compiling the Elixir AST into markup all in one pass and utilizing some global state to store the compiled markup.

Named Slots, the feature that I want to build before cutting the v0.6.0 release, would be extremely complex or impossible to write with the architecture I described above.

Let's discuss the AST and the benefits.

## Temple AST

The AST follows a basic tree structure. Below I've demonstrated how some code you've probably written before would be represented by the AST.

```elixir
form_for @conn, Routes.widget_path(@conn, :create), fn f->
  label f, :name do
    span class: "text-bold" do
      "Name:"
    end

    text_input f, :name, placeholder: "Name..."
  end
end

# parses into

%AnonymousFunctions{
  elixir_ast: # the quoted expression from above,
  children: [
    %DoExpressions{
      elixir_ast: {:label, [], [{:f, [], Elixir}, :name]},
      children: [
        %NonvoidElementsAliases{
          name: "span",
          attrs: [class: "text-bold"],
          children: [
            %Text{text: "Name:"}
          ]
        },
        %Default{
          elixir_ast:
            {:text_input, [], [{:f, [], Elixir}, :name, [placeholder: "Name..."]]}
        }
      ]
    }
  ]
}
```

The biggest benefit to the AST is its role as an _intermediate format_. Since we've explored the entire AST, we can now run it through another step before generating the final output. The goal is to target EEx, but now that we have the IF, we could write a generator that targets ANSI sequences for a CLI or maybe even [Scenic](https://github.com/boydm/scenic)!

This brings us to our next topic, protocols!

## Protocols

The EEX generator step utilizes a [protocol](https://elixir-lang.org/getting-started/protocols.html) to be able to compile Temple AST into an `iolist` that represents EEx.

Each AST module implements this protocol and this allows any protocol implementation to generate any child nodes it contains without concerning itself with the shape of the children.

The implementation for the `Text` node type is the easiest to understand.

```elixir
defmodule Temple.Parser.Text do
  # ...

  defimpl Temple.Generator do
    def to_eex(%{text: text}) do
      [text, "\n"]
    end
  end
end
```

The benefit of using a protocol becomes clear when we look at the `NonvoidElementsAliases` implementation. The highlighted line belows shows how the protocol makes recursively compiling the AST super easy.  

{% hl elixir hl="11" %}
defmodule Temple.Parser.NonvoidElementsAliases do
  # ...

  defimpl Temple.Generator do
    def to_eex(%{name: name, attrs: attrs, children: children}) do
      [
        "<",
        name,
        Temple.Parser.Utils.compile_attrs(attrs),
        ">\n",
        for(child <- children, do: Temple.Generator.to_eex(child)),
        "\n</",
        name,
        ">"
      ]
    end
  end
end
{% endhl %}

Since the implementation takes advantage of `iolist`s, we can easily compute the final markup without maintaining any state or dealing with cumbersome return values. Once `to_eex` returns, we just run that through `:erlang.iolist_to_binary/1` and we're good to go!

## What's Next

With a proper AST in place, I can now move forward with the Named Slots API, which is the missing piece of the puzzle to make the Component API _really_ slick.

Eventually, you should be able to write something like this. (The exact syntax is subject to change)

```elixir
c Card, data: @person do
  slot :header, %{data: person} do
    "Full name: #{person.first_name} #{person.last_name}" 
  end

  # some card body

  slot :footer, %{data: person} do
    "Find me on Twitter: "

    a href: "https:twitter.com/#{person.socials.twitter}" do
      "@" <> person.socials.twitter
    end
  end
end

c Card, data: @company do
  slot :header, %{data: company} do
    "Legal name: #{company.name}"
  end

  # some card body

  slot :footer, %{data: company} do
    "Contact support at:"

    a href: "tel:" <> company.phone_number do
      person.phone_number
    end
  end
end
```

See you next time!
