---
title: Building Websites with Tableau
description: |
    Tableau is a new static site generator for Elixir!

    In the spirit of going all in on Elixir tooling, I built Tableau to create the website for elixir-tools and Next LS. Since then, myself and others have migrated their blogs to Tableau as well as built whole new sites!

    Tableau makes it easy to create website that can be hosted on providers like Netlify, GitHub Pages, or even an S3 bucket, while getting to use the template engine you love (HEEx, Temple, Liquid) and all of your favorite Elixir packages (Req, ESBuild, Tailwind).

    Let's dive into Tableau and have some fun!

permalink: /:title/:slide
layout: Blog.PresentationLayout
---

# Building Websites with Tableau

## Mitchell Hanberg

---

# Who am I?

- I'm Mitch!
- Lead Software Engineer at DraftKings
- Founding member of the official Elixir Language Server team
- Author/maintainer of Elixir open source (Wallaby, Temple, elixir-tools, ...)
- Working with Elixir since ~2017

---

![picture of draftkings logo](/images/large-draftkings-logo.png)

---

# What is Tableau?

- Static Site Generator for the Elixir ecosystem
- Turns content files and markup into static HTML files
    - You usually shove the static files somewhere to host like Netlify, GitHub Pages, or a cloud bucket
- Originally built to create the website for elixir-tools/Next LS
    - Not Invented Here Syndrome is strong

---

# Built with Tableau

| Site                                                       | Template                                                                      | Styling    | Source                                                                            |
|------------------------------------------------------------|-------------------------------------------------------------------------------|------------|-----------------------------------------------------------------------------------|
| [www.elixir-tools.dev](https://www.elixir-tools.dev)       | [Temple](https://github.com/mhanberg/temple)                                  | Tailwind   | [elixir-tools/elixir-tools.dev](https://github.com/elixir-tools/elixir-tools.dev) |
| [www.mitchellhanberg.com](https://www.mitchellhanberg.com) | [Temple](https://github.com/mhanberg/temple)                                   | Tailwind   | [mhanberg/blog](https://github.com/mhanberg/blog)                                 |
| [pdx.su](https://pdx.su)                                   | [Temple](https://github.com/mhanberg/temple)                                  | CSS        | [paradox460/pdx.su](https://github.com/paradox460/pdx.su)                         |
| [Xmeyers](https://andyl.github.io/xmeyers)                 | [HEEx](https://hexdocs.pm/phoenix_live_view/Phoenix.Component.html#sigil_H/2) | Tailwind   | [andyl/xmeyers](https://github.com/andyl/xmeyers)                                 |
| [0x7f](https://0x7f.dev)                                   | [HEEx](https://hexdocs.pm/phoenix_live_view/Phoenix.Component.html#sigil_H/2) | magick.css | [0x7fdev/site](https://github.com/0x7fdev/site)                                   |
| Hackery                                                    | [HEEx](https://hexdocs.pm/phoenix_live_view/Phoenix.Component.html#sigil_H/2) | Tailwind   | [mhanberg/hackery](https://github.com/mhanberg/hackery)                           |
| [doneth.dev](https://doneth.dev)                           | [HEEx](https://hexdocs.pm/phoenix_live_view/Phoenix.Component.html#sigil_H/2) | Tailwind   | [JohnDoneth/doneth.dev](https://github.com/JohnDoneth/doneth.dev)                 |

---

# Built with Tableau

| Site                                                       | Template                                                                      | Styling    | Source                                                                            |
|------------------------------------------------------------|-------------------------------------------------------------------------------|------------|-----------------------------------------------------------------------------------|
| [joelkoch.dev](https://joelkoch.dev)                       | [HEEx](https://hexdocs.pm/phoenix_live_view/Phoenix.Component.html#sigil_H/2) | Tailwind   | [joelpaulkoch/joelkoch.dev](https://github.com/joelpaulkoch/joelkoch.dev)         |
| [www.ethangunderson.com](https://www.ethangunderson.com/)  | [HEEx](https://hexdocs.pm/phoenix_live_view/Phoenix.Component.html#sigil_H/2) | Tailwind   | [ethangunderson/website](https://github.com/ethangunderson/website)               |
| [https://adrienanselme.com/](https://adrienanselme.com/)   | [HEEx](https://hexdocs.pm/phoenix_live_view/Phoenix.Component.html#sigil_H/2) | Tailwind   | [adanselm/adanselm.github.io](https://github.com/adanselm/adanselm.github.io)     |

... and this presentation!


---

# PresentationExtension

- This entire slideshow is built into my website using a custom Tableau extension.

- Functions similarly to [DeckSet](https://www.deckset.com/), but uses the exact same theming and code highlighting as my blog.

---

# Let's create a website!

---

# mix tableau.new


We can use the `mix tableau.new` mix task to create our new website.

```
mix tableau.new <app_name> [<flags>]

Flags

--template    Template syntax to use. Options are heex, temple, eex. (optional, defaults to eex)
--js          JS bundler to use. Options are vanilla, bun, esbuild (optional, defaults to vanilla)
--css         CSS framework to use. Options are vanilla, tailwind. (optional, defaults to vanilla)
--help        Shows this help text.
--version     Shows task version.

Example

mix tableau.new my_awesome_site --template temple
mix tableau.new my_awesome_site --template eex --css tailwind
```

---

# Installing...

<style>
pre.athl {
  font-size: 24px !important;
}
</style>

Download the installer

```bash
$ mix archive.install hex tableau.new
```

Create our new site

```bash
$ mix tableau.new tims_toys \
    --template heex \
    --js bun \
    --css tailwind
```

---

<style>
pre.athl {
  font-size: 12px !important;
}
</style>

```bash
$ tree
.
├── _draft
├── _pages
├── _posts
├── _wip
├── assets
│   ├── css
│   │   └── site.css
│   └── js
│       └── site.js
├── config
│   ├── config.exs
│   ├── dev.exs
│   ├── prod.exs
│   └── test.exs
├── extra
├── formatter.exs
├── lib
│   ├── layouts
│   │   ├── post_layout.ex
│   │   └── root_layout.ex
│   ├── mix
│   │   └── tasks
│   │       └── post.ex
│   └── pages
│       └── home_page.ex
├── mix.exs
├── package.json
└── README.md

15 directories, 14 files

```

---

<style>
pre.athl {
  font-size: 20px !important;
}
</style>

```bash
$ tree
.
├── assets
│   ├── css
│   │   └── site.css
│   └── js
│       └── site.js
├── extra
├── lib
│   ├── layouts
│   │   ├── post_layout.ex
│   │   └── root_layout.ex
│   ├── mix
│   │   └── tasks
│   │       └── post.ex
│   └── pages
│       └── home_page.ex
├── mix.exs
└── package.json
```

---

# Mix tasks

- `mix tableau.build`: Build your static site
- `mix tableau.server`: Build your static site and serve it locally

---

# DX

- Live reloading
    - Make a change, save: watch it reload in the browser
- Asset runners
    - Similar to Phoenix, can set up packages like `tailwind` and `esbuild` to run in development
- These features are extracted into a hex package called `web_dev_utils`.

---

# Concepts

- Pages
- Layouts
- Extensions
- Content

---

# Pages

- Behaviour implementation with a `template/1` callback, which is implemented as a function component.
- The callback takes the `assigns` as an argument.
- Two special options
    - `:layout`
    - `:permalink`
- Extra options passed to the `using` macro are sent to the page as assigns.

---

# Pages

<style>
pre.athl {
  font-size: 20px !important;
}
</style>


```elixir
defmodule TimsToys.HomePage do
  use Tableau.Page,
    layout: TimsToys.RootLayout,
    permalink: "/",
    title: "Tim's Toys"

  use Phoenix.Component

  def template(assigns) do
    ~H"""
    <p>
      Welcome to Tim's Toys!
    </p>
    """
  end
end
```

---

# Layouts

- Layouts are similar very similar to what you've seen in other frameworks
- Behaviour implementation with a `template/1` callback, which is implemented as a function component.
- The callback takes the `assigns` as an argument.
- Layouts are declared by Pages and rendered automatically

---

# Layouts

```elixir
defmodule TimsToys.PostLayout do
  use Tableau.Layout, layout: TimsToys.RootLayout
  use Phoenix.Component

  def template(assigns) do
    ~H"""
    <%= {:safe, render(@inner_content)} %>
    """
  end
end
```
===

```elixir
defmodule TimsToys.RootLayout do
  use Tableau.Layout
  use Phoenix.Component

  def template(assigns) do
    ~H"""
    <html lang="en">
      <head>
        <title>{@page[:title]}</title>

        <link rel="stylesheet" href="/css/site.css" />
        <script src="/js/site.js" />
      </head>

      <body>
        <main>
          <%= render @inner_content %>
        </main>
      </body>

      <%= if Mix.env() == :dev do %>
          {Phoenix.HTML.raw(Tableau.live_reload(assigns))}
      <% end %>
    </html>
    """
    |> Phoenix.HTML.Safe.to_iodata()
  end
end
```

---

# Content

- At the end of they day, you're website is mostly just content. You want to be able to author it as quickly as possible and have it turn into HTML.

- Extensions are the key here, and there are several builtin extensions to get you started
    - `Tableau.PostExtension`
    - `Tableau.PageExtension`
    - `Tableau.DataExtension`

---

# PostExtension

- Turns a set of content files into website pages.
- Notably, they have the concept of a "date", which regular pages don't generally have.
- By default, converts Markdown files using the amazing `MDEx` library by [Leandro Pereira](https://github.com/leandrocp)
    - Can be configured to use any parser, like [Djot](https://github.com/paradox460/djot)

---

# PostExtension

<style>
pre.athl {
  font-size: 20px !important;
}
</style>

```markdown
---
layout: Blog.PostLayout
title: If You Don't Have Anything Valuable To Say... Say It Anyways
date: 2017-02-28 09:00:00 EST
categories: post
permalink: /post/2017/02/28/first-post/
---

## What does this mean?

In the professional world, feedback is incredibly important and can vastly
beneficial, but sometimes our fear of criticism can stop you from sharing,
which then inhibits you from learning. 

There's nothing I hate more than being wrong, more so than others knowing
I was wrong. Being able to leverage others knowledge to accelerate your
own growth is a key to success (in my opinion, this is the part where you
can tell me I'm wrong).
```

---

# PostExtension

```markdown
---
layout: Blog.PostLayout
title: "Metaprogramming Elixir: Book Review"
date: 2018-08-18 09:00:00 EST
categories: post
desc: Metaprogramming Elixir is a must read read for those looking to level up their Elixir skills!
permalink: /post/2018/08/18/metaprogramming-elixir-book-review/
tags: [elixir, book-review, reading]
book:
  title: Metaprogramming Elixir
  author: Chris McCord
  cover: metaprogramming-elixir-cover.jpg
  cover_alt: Cover of the book Metaprogramming Elixir
  goodreads_id: 24791466
  isbn: 978-1-68050-041-7
  recommendation: A Must Read
---

## Who is the target audience?

Advanced beginner to intermediate Elixir developers who have mastered the
syntax and basic structure of Elixir applications who want to add advanced
language features to their skill set.

```

---

# PostExtension

```elixir
defmodule Blog.PostLayout do
  use Tableau.Layout, layout: Blog.SidebarLayout

  def template(assigns) do
    temple do
      if @page[:book] do
        ~MD"""
        **Title**: <a href="https://goodreads.com/book/show/<%= @page.book.goodreads_id %>"><%= @page.book.title %></a>

        **Author**: <%= @page.book.author %>

        **Recommendation**: <%= @page.book.recommendation %>
        """HTML
      end

      render(@inner_content)
    end
  end
end
```

---

![](/images/screenshot-book-review.png)

---

# PageExtension

- The `PageExtension` is similar to the `PostExtension`, but doesn't have the concept of a "date"
- Good choice for documentation
    - See https://elixir-tools.dev/next-ls for an example
- Permalink is determined by the file path

---

# PageExtension


```
_pages
└── docs
    └── next-ls
        ├── changelog.md
        ├── code-actions.md
        ├── commands.md
        ├── compiler-diagnostics.md
        ├── completions.md
        ├── credo.md
        ├── document-symbols.md
        ├── editors.md
        ├── faq.md
        ├── find-references.md
        ├── formatting.md
        ├── go-to-definition.md
        ├── hover.md
        ├── installation.md
        ├── quickstart.md
        ├── spitfire.md
        ├── troubleshooting.md
        ├── workspace-folders.md
        └── workspace-symbols.md
```

---

![](/images/page-extension-example.png)

---

# DataExtension

- Store information in YAML, JSON, TOML, or even run an Elixir script!
- Loaded into the `@data` assign in your templates
- Very useful for large sets of static data, or data that frequently changes that you want to fetch externally and be used when rebuilding.

---

# DataExtension

```elixir
get = fn shelf ->
  Req.get!("https://www.goodreads.com/review/list/69703261.xml",
    params: [
      key: System.get_env("GOODREADS_KEY") || raise("GOODREADS_KEY is not set"),
      v: 2,
      shelf: shelf,
      per_page: 200
    ]
  ).body
  |> EasyXML.parse!()
end
```

===

```elixir
map = fn shelf, callback ->
  shelf
  |> EasyXML.xpath("//reviews/review")
  |> Enum.map(fn review ->
    title = review["//book/title_without_series"]

    callback.(review, %{
      "id" => review["//book/id"],
      "title" => title,
      "isbn" =>
        review[~s'//book/isbn[not(@nil="true")]/text()'] ||
          review[~s'//book/isbn13[not(@nil="true")]'],
      "asin" => review["//book/asin"],
      "image" => review["//book/image_url"],
      "author" => review["//book/authors/author/name"],
      "link" => review["//book/link"]
    })
  end)
end

get.("currently-reading")
|> map.(fn _, b ->
  Map.put(b, "currently_reading", true)
end)
```


---

# RSSExtension

- You can create an arbitrary number of feeds from your posts based on a set of include and exclude filters

```elixir
config :tableau, Tableau.RSSExtension,
  enabled: true,
  feeds: [
    full: [
      enabled: true,
      title: "Mitchell Hanberg's Blog",
      description: "Mitchell Hanberg's Blog"
    ],
    feed: [
      enabled: true,
      title: "Mitchell Hanberg's Blog",
      description: "Mitchell Hanberg's Blog",
      exclude: [tags: ["micro-post"]]
    ],
    micros: [
      enabled: true,
      title: "Micro posts by Mitchell Hanberg",
      description: "I rolled my own X dot com, but it's write-only and no one will ever read it.",
      include: [tags: ["micro-post"]]
    ]
  ]

```


---

# TagExtension

<style>
pre.athl {
  font-size: 24px !important;
}
</style>


- Gathers all posts with various tags and sets them in the assigns
- Generates a page for each tag, from a configured layout and permalink

```elixir
config :tableau, Tableau.TagExtension,
  enabled: true,
  layout: Blog.TagLayout,
  permalink: "/tags"
```
---

# Writing your own extension

- It's easy to write your own extension
- Callback for each phase of the build pipeline
    - pre_build
    - pre_render
    - pre_write
    - post_write
- Can manipulate the data, insert new data into the pipeline, and add pages to the "build graph"

---

# Example

```elixir

defmodule Blog.TOCExtension do
  use Tableau.Extension, priority: 200, key: :toc, enabled: true

  @impl Tableau.Extension
  def pre_build(token) do
    {:ok, counters_pid} = Agent.start_link(fn -> Map.new() end)

    posts =
      for post <- token.posts do
        doc = MDEx.parse_document!(post.body)
        toc = scan_headings(counters_pid, List.wrap(doc[MDEx.Heading]))

        Map.put(post, :toc, toc)
      end

    Agent.stop(counters_pid)

    {:ok, Map.put(token, :posts, posts)}
  end
end
```

---

# Example

![](/images/toc-example.png)

---

# Putting pages into the graph

<style>
pre.athl {
  font-size: 20px !important;
}
</style>


```elixir
@impl Tableau.Extension
def pre_render(token) do
  graph =
    Tableau.Graph.insert(
      token.graph,
      Enum.map(token.presentations, fn page ->
        %Tableau.Page{
          parent: page.layout,
          permalink: page.permalink,
          template: page.renderer,
          opts: page
        }
      end)
    )

  {:ok, Map.put(token, :graph, graph)}
end
```
---

# Odds and Ends

- https://github.com/elixir-tools/tableau
- https://mitchellhanberg.com
- https://github.com/mhanberg

---

# Thanks!
