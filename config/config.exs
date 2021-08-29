import Config

config :elixir, :time_zone_database, Tzdata.TimeZoneDatabase

config :tableau, :reloader,
  dirs: ["./lib/layouts/", "./lib/pages/", "./lib/components/", "./_posts", "./_site/css"]

config :tableau, :assets,
  node: [
    "./node_modules/.bin/tailwindcss",
    "--postcss",
    "-i",
    "./css/site.css",
    "-c",
    "./_includes/tailwind.config.js",
    "-o",
    "./_site/css/site.css",
    "--watch"
  ]

import_config "#{config_env()}.exs"
