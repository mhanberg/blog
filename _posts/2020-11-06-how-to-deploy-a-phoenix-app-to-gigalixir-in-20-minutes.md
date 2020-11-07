---
layout: post
title: "How to Deploy a Phoenix App to Gigalixir in 20 Minutes"
date: 2020-11-06 09:00:00 -04:00
categories: post
permalink: /:title/
---

<div class="flex justify-center py-8">
  <iframe width="560" height="315" src="https://www.youtube.com/embed/z2nko60GcGo" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>
</div>

This is a quick screencast to demonstrate how easy it is to deploy an Elixir application to [Gigalixir](https://gigalixir.com), a hosting platform built specifically for Elixir.

I included a condensed text version of the video for those who prefer it, but you can find the full guide [here](https://hexdocs.pm/phoenix/overview.html#content).

## Create the Phoenix App

```shell
# install the generator
$ mix archive.install hex phx_new 1.5.6

# generate the project
$ mix phx.new foobar

# cd into the directory
$ cd foobar

# create our database
$ mix ecto.create

# start the server
$ mix phx.server

# commit your code to git
$ git init && git commit -am 'Initial Commit'
```

## Prod Configuration

You will have to adjust some prod configuration for our app to work on Gigalixir. Let's make the following adjustments to the `config/prod.exs` file.

```diff
  config :foobar, FoobarWeb.Endpoint,
-   url: [host: "example.com", port: 80],
+   url: [host: "your-app-name.gigalixirapp.com", port: 443],
-   cache_static_manifest: "priv/static/cache_manifest.json"
+   cache_static_manifest: "priv/static/cache_manifest.json",
+   force_ssl: [rewrite_on: [:x_forwarded_proto]]
 
+ config :foobar, Foobar.Repo,
+   ssl: true
```

## Deploy to Gigalixir

```shell
# install gigalixir (using Homebrew)
$ brew tap gigalixir/brew && brew install gigalixir

# sign up for gigalixir
$ gigalixir signup

# log in to gigalixir
$ gigalixir login

# create the app
$ gigalixir create

# set up your buildpacks
$ echo "elixir_version=1.10.3" > elixir_buildpack.config
$ echo "erlang_version=22.3" >> elixir_buildpack.config
$ echo "node_version=12.16.3" > phoenix_static_buildpack.config

# commit those changes
$ git commit -am 'Set up gigalixir buildpacks'

# create your prod database
$ gigalixir pg:create --free

# deploy your app
$ git push gigalixir main

# open your prod app
$ gigalixir open
```
