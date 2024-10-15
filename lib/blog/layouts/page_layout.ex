defmodule Blog.PageLayout do
  use Tableau.Layout, layout: Blog.SidebarLayout
  use Blog.Component

  def template(assigns) do
    temple do
      div class: "prose-lg prose-invert prose-ul:list-disc prose-p:text-[22px]" do
        render(@inner_content)
      end
    end
  end
end
