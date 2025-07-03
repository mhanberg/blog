import Config

config :tableau, :reloader,
  patterns: [
    ~r"^lib/.*.ex",
    ~r"^(_posts|_drafts|_wip|_pages)/.*.md",
    ~r"^_data/.*.(yaml|json|toml)",
    ~r"^css/site.css",
    ~r"^js/index.js"
  ]

config :web_dev_utils, :reload_log, true
config :web_dev_utils, :reload_url, "'ws://' + location.host + '/ws'"

config :temple,
  engine: EEx.SmartEngine,
  attributes: {Temple, :attributes}

# config :tailwind,
#   version: "4.0.9",
#   default: [
#     args: ~w(
#     --input=css/site.css
#     --output=_site/css/site.css
#     )
#   ]

config :bun,
  version: "1.2.4",
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

config :tableau, :assets,
  tailwind: {Bun, :install_and_run, [:css, ~w(--watch)]},
  bun: {Bun, :install_and_run, [:default, ~w(--watch)]}

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

config :tableau, Tableau.TagExtension,
  enabled: true,
  layout: Blog.TagLayout,
  permalink: "/tags"

config :tableau, Tableau.RSSExtension,
  enabled: true,
  feeds: [
    feed: [
      enabled: true,
      title: "Mitchell Hanberg's Blog",
      description: "Mitchell Hanberg's Blog"
    ]
  ]

config :elixir, :time_zone_database, Tz.TimeZoneDatabase

import_config "#{Mix.env()}.exs"
