defmodule Blog.ConvertkitPage do
  use Tableau.Page, layout: Blog.ConvertkitLayout, permalink: "/convertkit"
  use Blog.Component

  def template _assigns do
    temple do
      c &subscribe/1
    end
  end
end
