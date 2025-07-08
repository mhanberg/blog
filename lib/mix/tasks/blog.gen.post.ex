defmodule Mix.Tasks.Blog.Gen.Post do
  use Mix.Task

  @shortdoc "Generate a new blog post"
  @moduledoc @shortdoc

  @doc false
  def run(argv) do
    Application.ensure_all_started(:telemetry)

    {opts, _args, _invalid} =
      OptionParser.parse(argv,
        strict: [draft: :boolean, kind: :string, title: :string, commit: :boolean]
      )

    {:ok, opts} = Schematic.unify(options(), opts)

    post_title =
      cond do
        opts[:kind] == "post" ->
          opts[:title] || Mix.shell().prompt("Title:") |> String.trim()

        opts[:kind] == "micro" ->
          idx = "_micros" |> File.ls!() |> Enum.count() |> Kernel.+(1)
          "Micro blog ##{idx}"

        true ->
          Mix.raise("Unknown post kind")
      end

    post_datetime = DateTime.now!("America/Indiana/Indianapolis")
    formatted_datetime = Calendar.strftime(post_datetime, "%B %d, %Y %I:%M:%S %p %Z")
    unix_datetime = DateTime.to_unix(post_datetime, :millisecond)
    file_name = Blog.slugify(post_title)

    dir =
      cond do
        opts[:draft] -> "_drafts"
        opts[:kind] == "post" -> "_posts"
        opts[:kind] == "micro" -> "_micros"
        true -> Mix.raise("Could not determine post directory based on supplied options")
      end

    file_path = Path.join(dir, "#{unix_datetime}-#{file_name}.md")

    if File.exists?(file_path) do
      Mix.raise("File already exists")
    end

    front_matter_prelude = """
    ---
    layout: Blog.PostLayout
    title: \"#{post_title}\"
    date: #{formatted_datetime}
    """

    permalink =
      if opts[:kind] == "micro" do
        "permalink: /micros/#{unix_datetime}/"
      else
        "permalink: /:title/"
      end

    tags =
      if opts[:kind] == "micro" do
        "tags: [micro-post]"
      else
        "tags: []"
      end

    body =
      if opts[:kind] == "micro" do
        tmp_dir = Path.join(System.tmp_dir!(), "#{unix_datetime}-micro.md")
        Mix.shell().cmd("nvim #{tmp_dir}", use_stdio: false)
        File.read!(tmp_dir)
      else
        ""
      end

    front_matter_postlude = "\n---\n\n"

    front_matter =
      front_matter_prelude <>
        Enum.join([permalink, tags], "\n") <>
        front_matter_postlude <> body

    File.write!(file_path, front_matter)

    Mix.shell().info("Succesfully created #{file_path}!")

    if opts[:kind] == "micro" and (opts[:commit] || Mix.shell().yes?("Commit?")) do
      if Mix.shell().cmd("git diff --cached --quiet") == 0 do
        Mix.shell().cmd("git add #{file_path}")
        Mix.shell().cmd(~s|git commit -m "feat(micro): #{file_path}"|)
      else
        Mix.shell().error("There are already staged changes, can't auto commit")
      end
    end
  end

  defp options do
    import Schematic

    keyword(%{
      optional(:kind, "post") => oneof(["post", "micro"]),
      optional(:draft, false) => bool(),
      optional(:title) => str(),
      optional(:commit, false) => bool()
    })
  end
end
