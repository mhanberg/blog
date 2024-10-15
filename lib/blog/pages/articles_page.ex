defmodule Blog.ArticlesPage do
  use Tableau.Page,
    layout: Blog.SidebarLayout,
    permalink: "/articles",
    title: "Articles | Mitchell Hanberg"

  use Blog.Component

  def template(assigns) do
    temple do
      section class: "mx-auto mb-8" do
        div class: "prose-lg prose-invert" do
          MDEx.to_html!("""
          # Articles

          Subscribe to my [mailing list](/newsletter) or [RSS](/feed.xml) feed to stay notified of new articles.
          """)
        end

        for post <- @posts do
          article class: "mt-8" do
            a class: "block text-2xl md:text-3xl text-white no-underline",
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
