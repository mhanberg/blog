defmodule Blog.PageLayout do
  use Tableau.Layout, layout: Blog.SidebarLayout
  use Blog.Component

  def template(assigns) do
    temple do
      c &prose/1 do
        render(@inner_content)
      end
    end
  end
end
