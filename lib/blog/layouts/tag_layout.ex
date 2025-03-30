defmodule Blog.TagLayout do
  use Tableau.Layout, layout: Blog.SidebarLayout
  use Blog.Component

  def template(assigns) do
    temple do
      c &prose/1 do
        h1 class: "text-4xl" do
          "Tag: #" <> @page.tag
        end

        for post <- @page.posts do
          article class: "mt-8" do
            a class: "font-fancy block font-normal text-2xl md:text-3xl no-underline",
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
