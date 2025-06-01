import Config

config :tableau, :config, url: "https://www.mitchellhanberg.com"
config :tableau, Tableau.PostExtension, future: false, dir: ["_posts"]

config :tableau, Tableau.PageExtension, dir: ["_pages"]
