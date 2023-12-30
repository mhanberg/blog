---
layout: Blog.PostLayout
title: "How I Handle Static Assets in my Phoenix apps"
date: 2021-06-07 01:00:00 -04:00
categories: post
permalink: /:title/
---

I no longer use [Webpack](https://webpack.js.org/).

Now I use [esbuild](https://esbuild.github.io/), [postcss-cli](https://github.com/postcss/postcss-cli), and [cpx](https://github.com/mysticatea/cpx).

- esbuild bundles and transpiles my JavaScript files extremely fast.
- postcss-cli processes my CSS and can run the [TailwindCSS JIT](https://tailwindcss.com/docs/just-in-time-mode) mode without any problems.
- cpx copies other static files from the `assets` directory into the `priv` directory.

Running each of these tools in development is just as easy as running Webpack.

```elixir
# config/dev.exs

esbuild = Path.expand("../assets/node_modules/.bin/esbuild", __DIR__)
config :my_app, MyAppWeb.Endpoint,
  http: [port: 4000],
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  watchers: [
    "#{esbuild}": [
      "./js/app.js",
      "--target=es2015",
      "--bundle",
      "--outdir=../priv/static/js",
      "--sourcemap",
      "--watch",
      cd: Path.expand("../assets", __DIR__)
    ],
    node: [
      "./node_modules/.bin/postcss",
      "./css/app.css",
      "--dir",
      "../priv/static/css",
      "-w",
      cd: Path.expand("../assets", __DIR__),
      env: [{"NODE_ENV", "development"}, {"TAILWIND_MODE", "watch"}]
    ],
    node: [
      "./node_modules/.bin/cpx",
      "'static/**/*'",
      "../priv/static",
      "--watch",
      cd: Path.expand("../assets", __DIR__)
    ]
  ]
```


## esbuild

![esbuild home page](https://res.cloudinary.com/mhanberg/image/upload/v1622864248/Screen_Shot_2021-06-04_at_11.36.48_PM.png)

esbuild is part of the newest generation of JavaScript tooling. It is built in [Go](https://golang.org/) and is _extremely_ fast. All I really need is my JavaScript to be bundled and transpiled to some degree, and esbuild does just that.

Since esbuild is not available in our path, we'll have to declare our watcher with the absolute path to the binary. To make this legible, I have pulled out the absolute path to a variable so it reads more like what we are used to.

## PostCSS

Since I'm are no longer using Webpack, I just use the `postcss-cli`.

The third highlighted line demonstrates that this configuration is really just a declarative way to run commands with [`System.cmd/3`](https://hexdocs.pm/elixir/System.html#cmd/2). This means I can use all the same options! I am using the new [TailwindCSS JIT](https://tailwindcss.com/docs/just-in-time-mode), which requires a couple of environment variables to be set, so I pass the `:env` option to include variables in the environment of PostCSS.

## cpx

Once I ditched Webpack, I realized that in addition to bundling my JS and CSS, it was responsible for copying my other static assets to the `priv` directory. Luckily there is this handy npm package called `cpx` that will watch a glob of directories and copy them somewhere else when it notices changes.

## Wrapping Up

The speed increase from switching from Webpack to esbuild is well worth the effort to make the switch.

Do you use something other than Webpack in your Phoenix applications? Let me know on [Twitter](https://twitter.com/mitchhanberg)!
