defmodule Blog.UsesPage do
  use Tableau.Page,
    layout: Blog.PageLayout,
    permalink: "/uses",
    title: "Uses"

  use Blog.Component

  def template(assigns) do
    temple do
      section do
        h1 do: "Uses"

        p do
          "No one ever asks me what font or syntax theme I use, but nevertheless here we are."
        end

        for category <- @data["uses"] do
          h2 do: category["name"]

          ul do
            for entry <- category["entries"] do
              li do
                span id: Blog.Filters.slugify(entry["name"]),
                     class: "text-whtie font-semibold" do
                  a href: entry["link"], target: "_blank", do: entry["name"]
                end
              end
            end
          end
        end
      end
    end
  end
end
