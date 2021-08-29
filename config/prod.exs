import Config

config :tableau, :assets,
  node: [
    "./node_modules/.bin/tailwindcss",
    "--postcss",
    "-i",
    "./css/site.css",
    "-c",
    "./_includes/tailwind.config.js",
    "-o",
    "./_site/css/site.css"
  ]
