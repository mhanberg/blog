defmodule Blog.ArticlesPage do
  use Tableau.Page,
    layout: Blog.PageLayout,
    permalink: "/articles",
    title: "Articles"

  use Blog.Component

  def template(assigns) do
    temple do
      section class: "mx-auto mb-8" do
        Blog.markdownify("""
        # Articles

        Subscribe to my [mailing list](/newsletter) or [RSS](/feed.xml) feed to stay notified of new articles.
        """)

        for post <- @posts, "micro-post" not in (post[:tags] || []) do
          article class: "mt-8" do
            a class: "font-fancy block font-light text-lg md:text-xl no-underline",
              href: post.permalink do
              post.title
            end

            div class: "text-sm italic mb-4" do
              Calendar.strftime(post.date, "%b %d, %Y")
              " • "
              "#{Blog.reading_time(post.body)} minute read"
            end
          end
        end
      end
    end
  end
end
