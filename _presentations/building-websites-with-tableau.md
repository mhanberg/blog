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

# What is Tableau?

- Static Site Generator for the Elixir ecosystem
- Turns content files and markup into static HTML files
- Originally built to create the website for elixir-tools/Next LS

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
