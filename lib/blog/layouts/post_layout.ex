defmodule Blog.PostLayout do
  use Tableau.Layout, layout: Blog.SidebarLayout
  use Blog.Component

  def template(assigns) do
    temple do
      c &prose/1 do
        h1 class: "text-3xl" do
          @page.title
        end

        div class: "flex gap-4 text-white text-sm" do
          c &date/1, date: @page.date
          c &reading_time/1, content: @page.body
          c &tags/1, tags: @page[:tags] || []
        end

        hr class: "!w-full border-fallout-green"

        render(@inner_content)

        hr class: "!w-full"

        div class: "text-center mx-auto" do
          c &convertkit/1
        end
      end
    end
  end
end
