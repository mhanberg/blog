defmodule Blog.ConvertkitLayout do
  use Tableau.Layout
  use Blog.Component

  def template(assigns) do
    temple do
      html lang: "en" do
        head do
          link rel: "preconnect", href: "https://fonts.googleapis.com"
          link rel: "preconnect", href: "https://fonts.gstatic.com", crossorigin: true

          link href: "https://fonts.googleapis.com/css2?family=Jersey+25&display=swap",
               rel: "stylesheet"
        end

        body do
          render(@inner_content)
        end
      end
    end
  end
end
