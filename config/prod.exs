import Config

config :tableau, :config, url: "https://www.mitchellhanberg.com"
config :tableau, Tableau.PostExtension, future: false, dir: ["_posts", "_micros"]

config :tableau, Tableau.PageExtension, dir: ["_pages"]
