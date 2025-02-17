defmodule Blog.MixProject do
  use Mix.Project

  def project do
    Code.put_compiler_option(:ignore_already_consolidated, true)

    [
      app: :blog,
      version: "0.1.0",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  def aliases() do
    [
      build: ["tableau.build", "tailwind default --minify"]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:tableau, "~> 0.20"},
      # {:tableau, path: "../tableau/", override: true},
      {:temple, "~> 0.12"},
      {:benchee, "~> 1.3"},
      {:bun, "~> 1.3"},
      {:tableau_og_extension, "~> 0.2"},
      {:schematic, "~> 0.4", override: true},
      {:floki, "~> 0.34"},
      {:req, "~> 0.4.8"},
      {:easyxml, "~> 0.1.0-dev", github: "wojtekmach/easyxml", branch: "main"},
      {:solid, "~> 0.15.2"},
      {:tailwind, "~> 0.2", runtime: Mix.env() == :dev}
    ]
  end
end
