import Config

config :tableau, :config, url: "https://www.mitchellhanberg.com"
config :tableau, Tableau.PostExtension, future: false

config :tableau, Tableau.PageExtension, dir: ["_pages"]
config :tableau, Tableau.PostExtension, future: true, dir: ["_posts"]
