---
layout: Blog.PostLayout
title: Experiment in the REPL
date: 2019-02-19 11:00:00 -04:00
categories: post
permalink: /:title/
---

A technique I've picked up for learning new tools is **experimenting with them in the REPL**.

>A read–eval–print loop (REPL), is a simple, interactive computer programming environment that takes single user inputs, evaluates them, and returns the result to the user. [\*](https://en.wikipedia.org/wiki/Read%E2%80%93eval%E2%80%93print_loop)

Elixir (`iex`), Ruby (`irb`), and Node.js (`node`) all have interactive shells that allow you to evaluate expressions easily and quickly.

This works great for small things like remembering how division works or grokking a tricky enumerable method.

```console
iex(1)> 1 / 2
0.5
iex(2)> div 1, 2
0
iex(3)> Enum.reject([1, 2, 3], fn n -> rem(n, 2) == 0 end)
[1, 3]
```

It's also a convenient way to try out new libraries.

```console
iex(4)> Slack.Web.Chat.post_message("C68FV6MDH", nil, %{attachments: [%{color: "good", text: "Hello world!"}]})
** (ArgumentError) argument error
    :erlang.list_to_binary([%{color: "good", text: "Hello world!"}])
    (hackney) /Users/mitchell/Development/my_app/deps/hackney/src/hackney_bstr.erl:36: :hackney_bstr.to_binary/1
    (hackney) /Users/mitchell/Development/my_app/deps/hackney/src/hackney_url.erl:300: :hackney_url.urlencode/2
    (hackney) /Users/mitchell/Development/my_app/deps/hackney/src/hackney_url.erl:360: :hackney_url.qs/3
    (hackney) /Users/mitchell/Development/my_app/deps/hackney/src/hackney_request.erl:310: :hackney_request.encode_form/1
    (hackney) /Users/mitchell/Development/my_app/deps/hackney/src/hackney_request.erl:318: :hackney_request.handle_body/4
    (hackney) /Users/mitchell/Development/my_app/deps/hackney/src/hackney_request.erl:81: :hackney_request.perform/2
    (hackney) /Users/mitchell/Development/my_app/deps/hackney/src/hackney.erl:373: :hackney.send_request/2
    (httpoison) lib/httpoison/base.ex:787: HTTPoison.Base.request/6
    (httpoison) lib/httpoison.ex:128: HTTPoison.request!/5
    (slack) lib/slack/web/web.ex:51: Slack.Web.Chat.post_message/3

# Turns out we need to JSON encode the attachments list
iex(5)>Slack.Web.Chat.post_message("C68FV6MDH", nil, %{attachments: Jason.encode!([%{color: "good", text: "Hello world!"}])})
%{
  "channel" => "C68FV6MDH",
  "ok" => true,
} 
```

I find experimenting in the REPL to be useful when I need a **short feedback loop** that isn't tightly coupled to the full stack of my application.

### Avoid Analysis Paralysis

>Analysis paralysis is when the fear of potential error outweighs the realistic expectation or potential value of success, and this imbalance results in suppressed decision-making in an unconscious effort to preserve existing options. [\*](https://en.wikipedia.org/wiki/Analysis_paralysis#Software_development)

Idle hands build nothing. I fell into this trap recently, wasting hours before I remembered the power of the REPL.

I knew I needed to use either a [Supervisor](https://hexdocs.pm/elixir/Supervisor.html) or a [Dynamic Supervisor](https://hexdocs.pm/elixir/DynamicSupervisor.html), but I wasn't sure which one was right for the job.

Unclear on how to proceed, I spent a **few hours** reading documentation, searching for blog posts, and asking people for advice. Did I learn enough to make a decision? _No_.

Then I spent **20 minutes** experimenting with them in `iex` and I knew which one to use.
