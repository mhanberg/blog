defmodule Blog.TagLayout do
  use Tableau.Layout, layout: Blog.SidebarLayout
  use Blog.Component

  def template(assigns) do
    temple do
      c &prose/1 do
        h1 class: "text-2xl" do
          "Tag: #" <> @page.tag
        end

        for post <- @page.posts do
          article class: "mt-8" do
            a class: "font-fancy block text-xl font-light no-underline",
              href: post.permalink do
              post.title
            end

            div class: "mb-4 text-sm italic" do
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
