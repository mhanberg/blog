defmodule Blog.PostLayout do
  use Tableau.Layout, layout: Blog.SidebarLayout
  use Blog.Component

  def template(assigns) do
    temple do
      article class: "prose-lg prose-invert max-w-[100ch]" do
        h1 class: "text-3xl" do
          @page.title
        end

        div class: "flex gap-4" do
          c &date/1, date: @page.date
          c &reading_time/1, content: @page.body
        end

        render(@inner_content)

        hr()

        div class: "text-center mx-auto" do
          c &subscribe/1
        end
      end
    end
  end
end
