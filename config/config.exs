import Config

config :tableau, :reloader,
  patterns: [
    ~r"^lib/.*.ex",
    ~r"^(_posts|_docs)/.*.md",
    ~r"^(_includes)/.*.html",
    ~r"^assets/*.(css|js)"
  ]

config :web_dev_utils, :reload_log, true
config :web_dev_utils, :reload_url, "'ws://' + location.host + '/ws'"

config :tailwind,
  version: "3.4.13",
  default: [
    args: ~w(
    --config=assets/tailwind.config.js
    --input=css/site.css
    --output=_site/css/site.css
    )
  ]

config :tableau, :assets, tailwind: {Tailwind, :install_and_run, [:default, ~w(--watch)]}

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
        autolink: true
      ],
      render: [unsafe_: true],
      features: [syntax_highlight_theme: "everforest_dark"]
    ]
  ]

config :tableau, Tableau.DataExtension, enabled: true

config :tableau, Tableau.OgExtension,
  enabled: true,
  template: {Blog.Og, :template}

config :tableau, Tableau.PageExtension, enabled: true
config :tableau, Tableau.PostExtension, enabled: true, future: true
config :tableau, Tableau.SitemapExtension, enabled: true

config :tableau, Tableau.RSSExtension,
  enabled: true,
  title: "Mitchell Hanberg's Blog",
  description: "Mitchell Hanberg's Blog"

config :elixir, :time_zone_database, Tz.TimeZoneDatabase

import_config "#{Mix.env()}.exs"
