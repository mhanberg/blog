defmodule Blog.BookshelfPage do
  use Tableau.Page,
    layout: Blog.SidebarLayout,
    permalink: "/bookshelf",
    title: "Bookshelf | Mitchell Hanberg"

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
      div class: "prose prose-invert prose-headings:font-normal max-w-4xl" do
        MDEx.to_html!("""
        # Bookshelf

        Reading has been one of my favorite hobbies ever since I was a kid. If you have any book suggestions or want to know how I felt about a book, hit me up on [Twitter](https://twitter.com/mitchhanberg)!

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
            "grid grid-cols-[repeat(auto-fill,50px)] gap-4 mt-8 has-[:not(.book:first-child:last-child)]:ml-4" do
        for book <- @books do
          c &book/1, book: book
        end
      end
    end
  end

  defp book(assigns) do
    temple do
      a href: @book["link"] || "#",
        target: "_blank",
        class:
          "book [&:not(:only-child)]:last:rotate-[-4deg] [&:not(:only-child)]:last:-translate-x-2 flex items-center text-sm py-4 border border-hacker h-[250px] w-[50px] [writing-mode:vertical-rl] rounded" do
        div class: "text-ellipsis overflow-hidden whitespace-nowrap" do
          @book["title"]
        end
      end
    end
  end
end
