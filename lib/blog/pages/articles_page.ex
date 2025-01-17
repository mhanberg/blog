defmodule Blog.ArticlesPage do
  use Tableau.Page,
    layout: Blog.PageLayout,
    permalink: "/articles",
    title: "Articles"

  use Blog.Component

  def template(assigns) do
    temple do
      section class: "mx-auto mb-8" do
        MDEx.to_html!("""
        # Articles

        Subscribe to my [mailing list](/newsletter) or [RSS](/feed.xml) feed to stay notified of new articles.
        """)

        for post <- @posts do
          article class: "mt-8" do
            a class: "font-fancy block font-normal text-2xl md:text-3xl no-underline",
              href: post.permalink do
              post.title
            end

            div class: "text-sm italic mb-4" do
              Calendar.strftime(post.date, "%b %d, %Y")
              " • "
              "#{Blog.Filters.reading_time(post.body)} minute read"
            end
          end
        end
      end
    end
  end
end
