import Config

config :tableau, :reloader,
  patterns: [
    ~r"^lib/.*.ex",
    ~r"^(_posts|_drafts|_micros|_wip|_pages|_presentations)/.*.md",
    ~r"^_data/.*.(yaml|json|toml)",
    ~r"^css/site.css",
    ~r"^js/index.js"
  ]

config :web_dev_utils, :reload_log, true
config :web_dev_utils, :reload_url, "'ws://' + location.host + '/ws'"

if mix_bun_path = System.get_env("MIX_BUN_PATH") do
  config :bun, path: mix_bun_path
end

config :tableau, :assets,
  tailwind: {Bun, :install_and_run, [:css, ~w(--watch)]},
  bun: {Bun, :install_and_run, [:default, ~w(--watch)]}

config :tableau, Tableau.PageExtension, dir: ["_pages", "_wip"]
config :tableau, Tableau.PostExtension, future: true, dir: ["_posts", "_micros", "_drafts"]
