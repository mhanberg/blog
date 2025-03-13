defmodule Mix.Tasks.Blog.Gen.Post do
  use Mix.Task

  @shortdoc "Generate a new blog post"
  @moduledoc @shortdoc

  @doc false
  def run(argv) do
    if argv == [] do
      raise "Missing argument: Filename"
    end

    post_title = Enum.join(argv, " ")
    post_date = Date.utc_today()
    post_time = "01:00:00 EST"

    file_name =
      post_title
      |> String.replace(" ", "-")
      |> String.replace("_", "-")
      |> String.replace(~r/[^[:alnum:]\/\-.]/, "")
      |> String.downcase()

    file_path =
      "./_posts/#{post_date}-#{file_name}.md"

    if File.exists?(file_path) do
      raise "File already exists"
    end

    front_matter = """
    ---
    layout: Blog.PostLayout
    title: \"#{post_title}\"
    date: #{post_date} #{post_time}
    permalink: /:title/
    ---
    """

    File.write!(file_path, front_matter)

    IO.puts("Succesfully created #{file_path}!")
  end
end
