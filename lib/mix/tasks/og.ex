defmodule Mix.Tasks.Blog.Gen.Og do
  use Mix.Task

  @shortdoc "Generate the OG Images"
  @moduledoc @shortdoc

  @doc false
  def run(_argv) do
    {:ok, _} = NodeJS.start_link(path: "priv/js", pool_size: 4)

    Application.put_env(:blog, :og_extension, true)

    Mix.Task.run("tableau.build")
  end
end
