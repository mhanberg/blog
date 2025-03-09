if File.exists?("_build/books.bin") do
  File.read!("_build/books.bin")
  |> :erlang.binary_to_term()
else
  get = fn shelf ->
    Req.get!("https://www.goodreads.com/review/list/69703261.xml",
      params: [
        key: System.get_env("GOODREADS_KEY") || raise("GOODREADS_KEY is not set"),
        v: 2,
        shelf: shelf,
        per_page: 200
      ]
    ).body
    |> EasyXML.parse!()
  end

  map = fn shelf, callback ->
    shelf
    |> EasyXML.xpath("//reviews/review")
    |> Enum.map(fn review ->
      title = review["//book/title_without_series"]

      callback.(review, %{
        "id" => review["//book/id"],
        "title" => title,
        "isbn" =>
          review[~s'//book/isbn[not(@nil="true")]/text()'] ||
            review[~s'//book/isbn13[not(@nil="true")]'],
        "asin" => review["//book/asin"],
        "image" => review["//book/image_url"],
        "author" => review["//book/authors/author/name"],
        "link" => review["//book/link"]
      })
    end)
  end

  currently_reading =
    get.("currently-reading")
    |> map.(fn _, b ->
      Map.put(b, "currently_reading", true)
    end)

  read =
    get.("read")
    |> map.(fn r, b ->
      # Sat Jan 01 00:00:00 -0800 2011 
      parts =
        Regex.named_captures(
          ~r/(?<weekday>\w+) (?<month>\w+) (?<day>\d{2}) (?<time>\d{2}:\d{2}:\d{2}) (?<offset>[-+]\d{4}) (?<year>\d{4})/,
          r["//read_at"]
        )

      read_at =
        DateTimeParser.parse_date!(
          # piece back together in a normal format
          "#{parts["month"]} #{parts["day"]} #{parts["year"]} #{parts["time"]} #{parts["offset"]}"
        )

      b
      |> Map.put("currently_reading", false)
      |> Map.put("date_read", read_at)
    end)
    |> Enum.sort_by(& &1["date_read"], {:desc, Date})

  books = currently_reading ++ read

  File.write!("_build/books.bin", :erlang.term_to_binary(books))

  books
end
