defimpl Solid.Matcher, for: Tuple do
  def match(data, []), do: {:ok, data}

  def match(data, ["size"]) do
    {:ok, tuple_size(data)}
  end

  def match(data, [key | keys]) when is_integer(key) do
    try do
      value = elem(data, key)
      @protocol.match(value, keys)
    rescue
      ArgumentError ->
        {:error, :not_found}
    end
  end
end

defmodule Blog do
  defmodule Filters do
    require Tableau.Document.Helper

    def render(inner_content) do
      Tableau.Document.Helper.render(inner_content)
    end

    def print(term) do
      dbg(term)
      ""
    end

    def markdownify(markdown) do
      MDEx.to_html(markdown)
    end

    def absolute_url(url) do
      host = Application.get_env(:tableau, :config)[:url]

      URI.parse(host) |> URI.merge(url) |> URI.to_string()
    end

    def book_url(links, goodreads_id) do
      link =
        links
        |> Enum.find(fn link ->
          link["id"] == goodreads_id
        end)

      Map.get(link, "link", "https://amazon.com/s?k=#{Base.url_encode64(link["title"])}")
    end

    def array_to_sentence_string(items) do
      Enum.join(items, ", ")
    end

    def group_by_year(books) do
      if books do
        books
        |> Enum.group_by(fn book ->
          DateTimeParser.parse_date!(book["date_read"]).year
        end)
        |> Enum.sort_by(fn {year, _} -> year end, :desc)
      else
        []
      end
    end

    def reading_time(post) do
      words = post["body"] |> String.split(" ") |> Enum.count()

      mins =
        if words < 360 do
          1
        else
          words / 180
        end
        |> ceil()

      "#{mins} minute read"
    end

    def get_review(id, posts) do
      (posts || [])
      |> Enum.find(fn post ->
        get_goodreads_id(post) == id
      end)
    end

    defp get_goodreads_id(post) do
      if post["book"] == nil do
        %{}
      else
        post["book"]["goodreads_id"]
      end
    end

    def slugify(str) do
      String.replace(str, " ", "-")
    end
  end

  defmacro sigil_L({:<<>>, _, [binary]}, []) do
    {:ok, template} = Solid.parse(binary)
    fs = Solid.LocalFileSystem.new("_includes", "%s.html")

    base =
      Macro.escape(%{
        tableau: %{
          environment: to_string(Mix.env())
        }
      })

    quote do
      case Solid.render(
             unquote(Macro.escape(template)),
             Blog.stringify(Map.merge(unquote(base), var!(assigns))),
             custom_filters: Blog.Filters,
             strict_variables: false,
             file_system: {Solid.LocalFileSystem, unquote(Macro.escape(fs))}
           ) do
        {:ok, iolist} ->
          iolist |> IO.iodata_to_binary()

        {:error, error, iolist} ->
          require Logger
          Logger.warning(inspect(error, pretty: true))
          iolist |> IO.iodata_to_binary()
      end
    end
  end

  def stringify(%struct{}) when struct not in [Date, DateTime, NaiveDateTime] do
    Map.from_struct(struct) |> stringify()
  end

  def stringify(%_struct{} = data) do
    data
  end

  def stringify(map) when is_map(map) do
    Map.new(map, fn
      {k, v} when is_atom(k) -> {to_string(k), stringify(v)}
      other -> other
    end)
  end

  def stringify(list) when is_list(list) do
    Enum.map(list, &stringify/1)
  end

  def stringify(other), do: other
end
