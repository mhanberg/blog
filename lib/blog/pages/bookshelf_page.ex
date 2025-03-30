defmodule Blog.BookshelfPage do
  use Tableau.Page,
    layout: Blog.PageLayout,
    permalink: "/bookshelf",
    title: "Bookshelf"

  use Blog.Component

  def template(assigns) do
    currently_reading = assigns.data["books"] |> Enum.filter(& &1["currently_reading"])

    years =
      assigns.data["books"]
      |> Enum.reject(& &1["currently_reading"])
      |> Enum.group_by(fn book -> book["date_read"].year end)
      |> Enum.sort_by(fn {year, _} -> year end, :desc)

    assigns =
      assigns
      |> Map.put(:years, years)
      |> Map.put(:currently_reading, currently_reading)

    temple do
      c &prose/1 do
        Blog.markdownify("""
        # Bookshelf

        Reading has been one of my favorite hobbies ever since I was a kid. If you have any book suggestions or want to know how I felt about a book, please send me an  [email!](mailto:mitch@mitchellhanberg.com)

        I pull this data from my [Goodreads](https://www.goodreads.com/review/list/69703261) account once a day.
        """)

        h2 class: "text-center underline mt-16", do: "Currently Reading"

        div class: "mt-8 font-mono" do
          c &books/1, books: @currently_reading

          for {year, books} <- @years do
            h2 class: "text-center mt-16", do: "#{year} (#{length(books)} books)"

            c &books/1, books: books
          end
        end
      end
    end
  end

  defp books(assigns) do
    temple do
      div class:
            "flex flex-wrap gap-x-[1px] items-end gap-y-2 mt-8 has-[:not(.book:first-child:last-child)]:ml-4" do
        for book <- @books do
          c &book/1, book: book
        end
      end
    end
  end

  defp book(assigns) do
    heights = ["h-[250px]", "h-[240px]", "h-[230px]"]
    widths = ["w-[41px]", "w-[59px]", "w-[91px]"]

    colors = ["bg-fallout-green", "bg-fallout-amber", "bg-fallout-light-blue", "bg-fallout-blue"]

    combos =
      for color <- colors, height <- heights, width <- widths do
        {color, height, width}
      end

    idx = :erlang.phash2(assigns.book["title"], length(combos))

    {color, height, width} = Enum.at(combos, idx)

    assigns =
      assigns
      |> Map.put(:color, color)
      |> Map.put(:height, height)
      |> Map.put(:width, width)

    temple do
      a href: @book["link"] || "#",
        title: @book["title"],
        target: "_blank",
        class:
          "book no-underline #{@color} [&:not(:only-child)]:last:rotate-[-4deg] [&:not(:only-child)]:last:translate-x-2 flex justify-between items-center text-sm #{@height} #{@width} [writing-mode:vertical-rl] rounded decoration-black border-t border-white inset-shadow-x" do
        div class:
              "text-ellipsis font-sans overflow-hidden whitespace-nowrap text-black pt-4 pb-2 h-full" do
          @book["title"]
        end
      end
    end
  end
end
