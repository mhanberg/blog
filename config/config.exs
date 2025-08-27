import Config

config :temple,
  engine: EEx.SmartEngine,
  attributes: {Temple, :attributes}

config :bun,
  version: "1.2.20",
  install: [
    args: ~w(install)
  ],
  css: [
    args: ~w(
    run tailwindcss
    --input=css/site.css
    --output=_site/css/site.css
    )
  ],
  default: [
    args: ~w(
    build 
    js/index.js  
    --outdir=_site/js
    )
  ]

config :tableau, :config,
  url: "http://localhost:4999",
  timezone: "America/Indiana/Indianapolis",
  markdown: [
    mdex: [
      extension: [
        table: true,
        header_ids: "",
        tasklist: true,
        strikethrough: true,
        autolink: true,
        alerts: true,
        footnotes: true
      ],
      render: [unsafe: true],
      syntax_highlight: [formatter: {:html_inline, theme: "neovim_dark"}]
    ]
  ]

config :tableau, Tableau.DataExtension, enabled: true

config :tableau, Tableau.OgExtension,
  enabled: true,
  template: {Blog.Og, :template}

config :tableau, Tableau.PageExtension, enabled: true
config :tableau, Tableau.PostExtension, enabled: true
config :tableau, Tableau.SitemapExtension, enabled: true

config :tableau, Tableau.PresentationExtension, enabled: true

config :tableau, Tableau.TagExtension,
  enabled: true,
  layout: Blog.TagLayout,
  permalink: "/tags"

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

config :elixir, :time_zone_database, Tz.TimeZoneDatabase

import_config "#{Mix.env()}.exs"
