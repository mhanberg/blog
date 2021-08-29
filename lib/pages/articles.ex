defmodule Blog.Pages.Articles do
  use Tableau.Page

  def post_url(post) do
    post.frontmatter["external_url"] || post.permalink
  end

  def post_target(post) do
    if post.frontmatter["external_url"] do
      "_blank"
    else
      "_self"
    end
  end

  def post_date(post) do
    {:ok, date, _} = DateTime.from_iso8601(post.frontmatter["date"])

    Calendar.strftime(date, "%B %-d, %Y")
  end

  def updated_on_date(post) do
    {:ok, date, _} = DateTime.from_iso8601(post.frontmatter["date"])

    Calendar.strftime(date, "%B %-d, %Y")
  end

  def reading_time(post) do
    word_count =
      post.content
      |> String.split()
      |> Enum.count()

    minutes =
      if word_count < 360 do
        1
      else
        div(word_count, 180)
      end

    "#{minutes} minute read"
  end

  render do
    section class: "max-w-2xl mx-auto mb-8" do
      h1 class: "md:text-5xl", do: "Articles"

      p class: "text-sm md:mb-8 mt-2" do
        "Subscribe to my "
        a! href: "/newsletter", do: "mailing list"
        " or "
        a! href: "/feed.xml", do: "RSS"
        " feed to stay notified of new articles."
      end

      for %Tableau.Post{} = post <- @posts do
        article class: "mt-8" do
          a class: "block text-xl md:text-2xl text-white no-underline",
            href: post_url(post),
            target: post_target(post) do
            post.frontmatter["title"]
          end

          div class: "text-sm italic mb-4" do
            post_date(post) <> " • " <> reading_time(post)
          end
        end
      end
    end
  end
end
