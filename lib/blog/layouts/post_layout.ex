defmodule Blog.PostLayout do
  use Tableau.Layout, layout: Blog.SidebarLayout
  use Blog.Component

  def template(assigns) do
    temple do
      article class:
                "prose prose-invert prose-a:text-hacker prose-p:text-white prose-headings:font-normal max-w-4xl mx-auto" do
        h1 class: "text-3xl" do
          @page.title
        end

        div class: "flex gap-4 text-white text-sm" do
          c &date/1, date: @page.date
          c &reading_time/1, content: @page.body
        end

        hr class: "border-hacker"

        render(@inner_content)

        hr()

        div class: "text-center mx-auto" do
          c &convertkit/1
        end
      end
    end
  end
end
