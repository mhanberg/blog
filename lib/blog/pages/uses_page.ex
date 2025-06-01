defmodule Blog.UsesPage do
  use Tableau.Page,
    layout: Blog.PageLayout,
    permalink: "/uses",
    title: "Uses"

  use Blog.Component

  def template(assigns) do
    temple do
      h1 do: "Uses"

      p do
        "No one ever asks me what font or syntax theme I use, but nevertheless here we are."
      end

      for category <- @data["uses"] do
        h2 do
          # this is a hack to get the whitespace correct. unclear if this can be improved in temple
          ~s|<a id="#{Blog.slugify(category["name"])}" class="anchor" href="##{Blog.slugify(category["name"])}" aria-hidden></a>#{category["name"]}|
        end

        if category["description"] do
          p do
            Blog.markdownify(category["description"])
          end
        end

        ul do
          for entry <- category["entries"] do
            li do
              span class: "group inline-flex items-center gap-2 text-white font-semibold" do
                a href: entry["link"],
                  target: "_blank",
                  do: entry["name"]

                a id: Blog.slugify(entry["name"]),
                  href: "##{Blog.slugify(entry["name"])}",
                  class: "hidden group-hover:inline scroll-m-16" do
                  c &link_icon/1, class: "size-4 text-white"
                end
              end
            end
          end
        end
      end
    end
  end
end
