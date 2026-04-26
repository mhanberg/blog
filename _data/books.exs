if File.exists?("_build/books.bin") do
  File.read!("_build/books.bin")
  |> :erlang.binary_to_term()
else
  get = fn shelf ->
    "https://api.hardcover.app/v1/graphql"
    |> Req.post!(
      headers: [
        {"Authorization", System.fetch_env!("HARDCOVER_TOKEN")}
      ],
      json: %{
        query: """
        query Shelf {
          user_books(
            where: {user_id: {_eq: 58924}, status_id: {_eq: #{shelf}}}
            order_by: {last_read_date: desc_nulls_last}
          ) {
            id
            rating
            date_added
            last_read_date
            user_book_status {
              status
            }
            book {
              id
              title
              slug
              contributions {
                author {
                  name
                }
              }
              pages
              image {
                url
              }
            }
            edition {
              pages
              isbn_10
              isbn_13
              asin
            }
          }
        }
        """,
        operationName: "Shelf"
      }
    )
    |> Map.fetch!(:body)
    |> get_in(["data", "user_books"])
  end

  map = fn shelf, callback ->
    shelf
    |> Enum.map(fn item ->
      book = item["book"]
      title = book["title"]

      callback.(item, %{
        "id" => book["id"],
        "status" => item["user_book_status"]["status"],
        "pages" => item["edition"]["pages"] || book["pages"],
        "title" => title,
        "isbn" => book["edition"]["isbn13"] || book["edition"]["isbn10"],
        "asin" => book["edition"]["asin"],
        "image" => book["image"]["url"],
        "author" => Enum.map_join(book["contributions"], ", ", & &1["author"]["name"]),
        "link" => Path.join(["https://hardcover.app", "books", book["slug"]])
      })
    end)
  end

  status_by_label = %{currently_reading: 2, read: 3}

  currently_reading =
    status_by_label.currently_reading
    |> get.()
    |> map.(fn _, b ->
      Map.put(b, "currently_reading", true)
    end)

  read =
    status_by_label.read
    |> get.()
    |> map.(fn item, b ->
      b
      |> Map.put("currently_reading", false)
      |> Map.put("date_read", DateTimeParser.parse!(item["last_read_date"] || item["date_added"]))
    end)
    |> Enum.sort_by(& &1["date_read"], {:desc, Date})

  books = currently_reading ++ read

  File.write!("_build/books.bin", :erlang.term_to_binary(books))

  books
end
