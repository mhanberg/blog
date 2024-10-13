defmodule Blog.PostLayout do
  import Blog
  use Tableau.Layout, layout: Blog.RootLayout
  use Blog.Component

  def template(assigns) do
    temple do
      render(@inner_content)
    end
  end
end
