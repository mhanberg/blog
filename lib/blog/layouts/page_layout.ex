defmodule Blog.PageLayout do
  use Tableau.Layout, layout: Blog.SidebarLayout
  use Blog.Component

  def template(assigns) do
    temple do
      div class:
            "prose prose-invert prose-ul:list-disc prose-headings:font-normal prose-a:text-fallout-green max-w-4xl mx-auto" do
        render(@inner_content)
      end
    end
  end
end
