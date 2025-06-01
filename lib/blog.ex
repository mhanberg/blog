defmodule Blog do
  def og_image_url(permalink) do
    file = Tableau.OgExtension.file_name(permalink)

    Path.join("https://f005.backblazeb2.com/file/BlogOgImages/og", file)
  end

  def markdownify(markdown) do
    MDEx.to_html!(markdown)
  end

  def absolute_url(url) do
    host = Application.get_env(:tableau, :config)[:url]

    host
    |> URI.parse()
    |> URI.merge(url)
    |> URI.to_string()
  end

  def book_url(links, goodreads_id) do
    link =
      Enum.find(links, fn link ->
        link["id"] == goodreads_id
      end)

    Map.get(link, "link", "https://amazon.com/s?k=#{Base.url_encode64(link["title"])}")
  end

  def array_to_sentence_string(items) do
    Enum.join(items, ", ")
  end

  def to_date_time(datetime) do
    DateTimeParser.parse_datetime!(datetime)
  end

  def group_by_year(books) do
    if books do
      books
      |> Enum.group_by(fn book ->
        book["date_read"].year
      end)
      |> Enum.sort_by(fn {year, _} -> year end, :desc)
    else
      []
    end
  end

  def reading_time(content) do
    words = content |> String.split(" ") |> Enum.count()

    mins =
      if words < 360 do
        1
      else
        words / 180
      end
      |> Kernel./(2)
      |> ceil()

    mins
  end

  def reload(env) do
    if env == "dev" do
      Tableau.live_reload(%{})
    else
      ""
    end
  end

  def get_review(id, posts) do
    Enum.find(posts || [], fn post ->
      get_goodreads_id(post) == id
    end)
  end

  defp get_goodreads_id(post) do
    unless post["book"] do
      %{}
    else
      post["book"]["goodreads_id"]
    end
  end

  def slugify(str) do
    str |> String.replace(" ", "-") |> String.downcase()
  end
end
